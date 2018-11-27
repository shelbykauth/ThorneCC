# Thorne ComputerCraft
A small collection of useful programs and apis.

## Programs
+ Inventory (WIP)
+ Shop (Future)
+ ChestBenchmark (Done)

## ThorneAPI Functions
+ Hash()
  - For secure password checking
+ Alert()
  - Checks for a speaker peripheral and plays a note
+ SaveObject(obj, path)
  - Serializes and saves object at specified path
+ LoadObject(path, default, writeDefault)
  - Loads and unserializes object from specified path
  - If object doesn't exist at path, it returns the second parameter
  - If writeDefault is true, and object at path doesn't exist, it saves the default to the path.
+ GetCenteredString(str)
  - Pads the str with leading and trailing spaces until it's the right length
+ ConfirmBox (Question, YesFunction, NoFunction)
  - Asks if you want to do the thing or not.
  - if NoFunction is not provided, an empty function will be executed.
+ followTree(path, tree, findingType)
  - Basically unpacks the path, but in a tree[path[1]][path[2]][path[3]][...] pattern
+ ComplexSelectionScreen(lines, selected, options, controls)
  - Scrolls through list of lines
  - Options
+ SimpleSelectionScreen(lines, selected, options)
  - Uses ComplexSelectionScreen, with a specific set of controls.
+ CenterPrint(lines, y)
  - Prints lines centered, starting at y height or in the center of screen
+ LoadingScreen(text, currentCount, finalCount)
  - Displays a formatted loading screen
+ Display (lines, scroll, highlight, options)
  - Displays series of lines at specified scroll height

## InventoryAPI Functions
+ start ()
+ reset ()
+ loadSettings ()
+ loadItemList ()
+ loadChests ()
+ saveSettings(newSettings)
+ loadItem (rawName)
+ recordItemAt (chestName, slot)
+ verifyItemLocatons (rawName)
+ getChestAndSlot(locationName)
+ getFirstAvailableSpot(itemName)
+ getNextAvailableSpot(startChestName, startSlot, itemName)
+ checkRetrieve ()
+ checkDump()
+ dump(chest, slot)
+ retrieve(item, count, chest, slot)
+ resetItemLocations()
+ resetChestList()
+ chooseRetrievalChest ()
+ getDisplayLine(rawName)
+ listItems ()
+ itemInfoScreen(selected)
+ dumpItem(selection)
+ retrieveItem(selection)
+ sortScreen()
+ sortBy(key)
+ filterScreen()
+ recountEverything()

## BenchmarkAPI
+ BenchmarkFunction(func, argsList, count)
  - Benchmarks a function passed in with parameters
  - argsList is a multidimensional array, {p1List, p2List, p3List, ...}, for all the combinations of arguments.
  - count defaults to 1000
+ BenchmarkProgram(path, argsList, count)
  - Benchmarks a program (found by absolute path) with arguments.
  - argsList same setup as above.
  - count defaults to 1000
+ FormatBenchmarkFunction(name, func, argsList, count)
  - Name your function test.  Returns a formatted string describing the test and how long it took.
