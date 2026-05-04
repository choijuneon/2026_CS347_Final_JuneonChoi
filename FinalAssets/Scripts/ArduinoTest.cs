using Godot;
using System;
using System.IO.Ports;
using System.Collections.Generic;
using System.Threading.Tasks;
 
public partial class ArduinoTest : Node
{
	// Main serial port for input, static so they persist between scenes
	public static SerialPort serialPort;
	public static SerialPort serialPort2;
	// The Message received from the arduino
	String serialMessage;
	// The last non-duplicate message
	String lastMessage;
	// all active serial ports
	List<SerialPort> activePorts = new List<SerialPort>();
	// stores the names of claimed ports
	private static HashSet<string> claimedPorts = new HashSet<string>();
	private int BaudRate = 9600;
	private int index = 0; // for testing LEDs, not part of main code
	// Delegates
	[Signal]
	delegate void buttonPushedEventHandler(); // left, black
	[Signal]
	delegate void button2PushedEventHandler(); // right,red
	[Signal]
	delegate void button3PushedEventHandler(); // up,yellow
	[Signal]
	delegate void button4PushedEventHandler(); // down,blue
	[Signal]
	delegate void button5PushedEventHandler(); // down,green
	[Signal]
	delegate void maintenancePushedEventHandler(int index);
	[Signal]
	delegate void potInputEventHandler(int index, int output);
	// The delegates below are for the main menu indicator
	[Signal]
 	delegate void probingEventHandler();
	[Signal]
	delegate void successEventHandler();
	[Signal]
	delegate void failureEventHandler();
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// Get potMinigame signal
		var potMinigame = GetParent().FindChild("MaintenanceMinigame", true, false);
 
		if (potMinigame != null)
		{
			potMinigame.Connect("potLed", Callable.From<string, string>(writeLeds));
			GD.Print("Successfully connected to PotMinigame signal!");
		}
		// Get hearbeatMinigame signal
		var heartbeatMinigame = GetParent().FindChild("HeartbeatMinigame", true, false);
 
		if (heartbeatMinigame != null)
		{
			heartbeatMinigame.Connect("heartLed", Callable.From<string, string>(writeLeds));
			GD.Print("Successfully connected to HeartbeatMinigame signal!");
		}
		// Get coolantMinigame signal
		var coolantMinigame = GetParent().FindChild("CoolantMinigame", true, false);
 
		if (coolantMinigame != null)
		{
			coolantMinigame.Connect("heartLed", Callable.From<string, string>(writeLeds));
			GD.Print("Successfully connected to CoolantMinigame signal!");
		}
		// Find custom controller
		if(serialPort == null && serialPort2 == null)
		{ 
			DetectArduinoPorts("1", "2"); 
		}
		// Turn all LEDs on scene load
		turnOnLeds();
	}
 
	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (serialPort == null) return;
		// Ignore code if port isn't open
		if (!serialPort.IsOpen) return;
 
		serialPort.ReadTimeout = 1;  // very short timeout
 
		try
		{
			// Read serial message from serial port
			serialMessage = serialPort.ReadLine().Trim();
		}
		catch (TimeoutException)
		{
			// No data this frame, continue normally
		}
 
		if (string.IsNullOrEmpty(serialMessage)) return;
		//GD.Print("RAW: " + serialMessage); // For debug purposes, comment out when not needed
		ParseMessage(serialMessage);
	}
 
	// Reads serial port messages and determine if they're a button input or potentiometer input
	void ParseMessage(string msg)
	{
 
		// Prevents serialMessage spam
		if (msg == lastMessage) { return; }
		lastMessage = msg;
 
		string[] parts = msg.Split('|');
 
		if (parts.Length < 2) return;
 
		int deviceId = int.Parse(parts[0]);
		string type = parts[1];
 
		switch (type)
		{
			case "B"://button pressed
				int pin = int.Parse(parts[2]);
				GD.Print($"Device {deviceId} Button {pin} DOWN");
				break;
 
			case "EB"://exit button
				pin = int.Parse(parts[2]);
				GD.Print($"Device {deviceId} Button {pin} UP");
				EmitButtonSignal(pin);
				break;
			case "M"://maintainence button pressed
				pin = int.Parse(parts[2]);
				GD.Print($"Device {deviceId} Button M{pin} DOWN");
				break;
			case "EM"://exit maintainence
				pin = int.Parse(parts[2]);
				GD.Print($"Device {deviceId} Button M{pin} UP");
				EmitSignal(SignalName.maintenancePushed, pin);
				break;
 
			case "P"://potentiometer
				string[] pot = parts[2].Split(':');
				int index = int.Parse(pot[0]);
				int value = int.Parse(pot[1]);
				GD.Print($"Device {deviceId} Pot {index} = {value}");
				EmitPotSignal(index, value);
				break;
			case "H":
				// This case is specifically for the heartbeat code
				break;
		}
	}
 
	// Outputs the signals for each button and their current state
	void EmitButtonSignal(int pin)
	{
		switch (pin)
		{
			case 2://black
				Callable.From(() => EmitSignal(SignalName.buttonPushed)).CallDeferred();
				break;
			case 3://red
				Callable.From(() => EmitSignal(SignalName.button2Pushed)).CallDeferred();
				break;
			case 4://yellow
				Callable.From(() => EmitSignal(SignalName.button3Pushed)).CallDeferred();
				break;
			case 5://blue
				Callable.From(() => EmitSignal(SignalName.button4Pushed)).CallDeferred();
				break;
			case 6: //black
				Callable.From(() => EmitSignal(SignalName.buttonPushed)).CallDeferred();
				break;
			case 7://red
				Callable.From(() => EmitSignal(SignalName.button2Pushed)).CallDeferred();
				break;
			case 8://yellow
				Callable.From(() => EmitSignal(SignalName.button3Pushed)).CallDeferred();
				break;
			case 9://green
				Callable.From(() => EmitSignal(SignalName.button5Pushed)).CallDeferred();
				break;
			case 10://blue
				Callable.From(() => EmitSignal(SignalName.button4Pushed)).CallDeferred();
				break;
			case 11://yellow
				Callable.From(() => EmitSignal(SignalName.button3Pushed)).CallDeferred();
				break;
			case 12://red
				Callable.From(() => EmitSignal(SignalName.button2Pushed)).CallDeferred();
				break;
			case 13://black
				Callable.From(() => EmitSignal(SignalName.buttonPushed)).CallDeferred();
				break;
		}
	}
 
	// Emits signals for each poteniometer and their current voltage
	void EmitPotSignal(int index, int output)
	{
		//EmitSignal(SignalName.potInput, index, output);
		Callable.From(() => EmitSignal(SignalName.potInput, index, output)).CallDeferred();
	}
	// Checks all serial ports for available arduinos
	async void DetectArduinoPorts(string id1, string id2)
	{
		await Task.Run(() =>
		{
			string[] ports;
			Callable.From(() => EmitSignal(SignalName.probing)).CallDeferred();
			try
			{
				ports = SerialPort.GetPortNames();
			}
			catch (Exception e)
			{
				GD.PrintErr($"Failed to get port names: {e.Message}");
				return;
			}
			GD.Print($"Available ports: {string.Join(", ", ports)}");
			foreach (string portName in ports)
			{
				if (claimedPorts.Contains(portName))
				{
					GD.Print($"Skipping {portName}, already claimed.");
					continue;
				}
				GD.Print($"Probing {portName}...");
				SerialPort testPort = null;
				try
				{
					testPort = new SerialPort(portName, BaudRate);
					testPort.NewLine = "\n";
					testPort.ReadTimeout = 500;
					testPort.Open();
					// Wait for Uno bootloader to finish resetting
					System.Threading.Thread.Sleep(2000);
					testPort.DiscardInBuffer();
					// Send identification request
					testPort.WriteLine("WHO");
					bool matched = false;
					var deadline = DateTime.Now + TimeSpan.FromSeconds(3);
					while (DateTime.Now < deadline)
					{
						try
						{
							string line = testPort.ReadLine().Trim();
							GD.Print($"  {portName} says: {line}");
							if (line.StartsWith(id1))
							{
								claimedPorts.Add(portName);
								activePorts.Add(testPort);
								serialPort = testPort;
								GD.Print($"[Device 1] Connected on {portName}");
								matched = true;
								break; // stop reading this port, move to next
							}
							else if (line.StartsWith(id2))
							{
								claimedPorts.Add(portName);
								activePorts.Add(testPort);
								serialPort2 = testPort;
								GD.Print($"[Device 2] Connected on {portName}");
								matched = true;
								// Set all lights to on by default
								turnOnLeds();
								break;
							}
						}
						catch (TimeoutException)
						{
							System.Threading.Thread.Sleep(10);
						}
					}
					// Only close if not claimed
					if (!matched)
					{
						GD.Print($"No match on {portName}, closing.");
						testPort.Close();
						testPort.Dispose();
					}
				}
				catch (Exception e)
				{
					GD.Print($"Error probing {portName}: {e.Message}");
					try { testPort?.Close(); } catch { }
					testPort?.Dispose();
				}
			}
			GD.Print("Probing complete!");
			checkConnection();
		});
	}
	
	public void checkConnection(){
		if (claimedPorts.Count >= 2) 
			{
				GD.Print("Both Arduinos found!");
				Callable.From(() => EmitSignal(SignalName.success)).CallDeferred();
			}
			else 
			{
				GD.Print("Failed to find both Arduinos.");
				Callable.From(() => EmitSignal(SignalName.failure)).CallDeferred();
			}
	}
	
	public void writeLeds(String index, String state){
		if(serialPort2 != null){
			serialPort2.WriteLine(index + "|" + state);
		}
	}
 
	public void turnOnLeds()
	{
		for (int i = 0; i < 18; i++)
		{
			writeLeds(i.ToString(), "1");
		}
		writeLeds("10","0");//turn of red pot leds on setup
		writeLeds("7","0");
		writeLeds("6","0");
		writeLeds("8","0");
		writeLeds("11","0");
		writeLeds("9","0");
	}
 
	// For debuging LEDs
 	/*
	public override void _Input(InputEvent @event)
	{
		if(@event.IsActionPressed("simonLeft")){
			writeLeds(index.ToString(), "1");
			GD.Print("Turning off led: " + index.ToString());
			index++;
		}
	}
	*/
}
