# SignalVisualizer
A plugin for Godot 4.x. SignalVisualizer displays the current scene's signals and connections in a easy to read graph and tree dock.

![Signal Visualizer plugin running Godot 4.x](./ImageSignalVisualizerDemo.png)

## Installation

The SignalVisualizer plugin can be installed via Godot's Asset Library or from source.

### Source Installation via Github

1. Download the repo
2. Copy the `addons/SignalVisualizer` directory to your project's `res://addons/` directory.
3. Enable the plugin under Project Settings -> Plugins

![Plugins Tab in Godot Project Settings](./ImagePluginScreenshot.png)

4. Ensure the Autoload singleton is enabled. The plugin adds the autoload automatically.

![Autoload Tab in Godot Project Settings](./ImageAutoloadScreenshot.png)

5. The `Signal Visualizer` tab will display in the bottom dock region. 

![Godot 4.x bottom dock displaying Signal Visualizer tab](./ImageSignalVisualizerDockScreenshot.png)

## Usage

Signal Visualizer will create a signal graph by mapping the signals in the current scene in the Godot editor. The bottom dock uses the built-in GraphEdit and Tree nodes to display the signal graph. Only signals with the flag of `CONNECT_PERSIST` will be displayed in the signal graph. In addition, all nodes that begin with `@` in the name will be ignored.

1. With your scene open in the editor, open the bottom dock.
2. In Signal Visualizer's top toolbar, click "Generate Graph"

![Signal Visualizer plugin toolbar. Clear graph and Generate graph buttons.](./ImageSignalVisualizerToolbarScreenshot.png)

### Format

In the signal graph and tree, the format is as follows:

#### Outgoing Signal

```
Signal -> Connected Node
```

![Player Node Outgoing Signals](./ImageOutgoingSignalScreenshot%20.png)

#### Incoming Signal

```
Signal::Callable Method
```

![GameUI Node Incoming Signals](./ImageIncomingSignalScreenshot.png)