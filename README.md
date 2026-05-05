# <div align="center"> [BetterMarketplace](https://create.roblox.com/store/asset/100470095583172) [v2.0.0] </div>
A ROBLOX Module that allows you to utilize MarketPlaceService in many better ways!

### Supports:
* Easier GamePass/DeveloperProduct Prompting (no need to type IDs manually!)
* Advanced Configuration Settings 
* Products with Limited Stocks (i.e., 149 Left!) 
* Gamepass/Product Gifting Built-In 
* DataStore Item Saving 
* **..And more!**

# <div align="center"> Documentation </div>

## Server Usage
### `BetterMarketplace.server.prompt`
**prompt** allows you to prompt the user to buy passes/developer products using 2-3 parameters. 
* `prompt(Player: Player, Name: string, Options: {[string]: any}?)`
* **Player** -> Self explanatory. Put the Player Instance here.
* **Name** -> Put the name of the GamePass/Developer Product here that you put inside of `BetterMarketplace/@settings`.
* **Options** *(optional)* -> Allows you to add extra configurations to your prompts. There are currently two.
  * ***DelayPrompts*** - A boolean value that decides if stacked prompts should be delayed. For instance; if someone gets prompted while having a prompt already up, it will get delayed and sent after the current prompt is closed.
  * ***Gifting*** - A string value of the username the player wants to gift to. If the gifted player isn't in server, the person buying the pass/product will get the perks instead.
## Client Usage
### `BetterMarketplace.client.prompt`
**prompt** is very similar to its server counterpart, but with one less parameter. 
 * `prompt(Name: string, Options: {[string]: any}?)`
 * **Name** -> Put the name of the GamePass/Developer Product here that you put inside of `BetterMarketplace/@settings`.
 * **Options** *(optional)* -> Allows you to add extra configurations to your prompts. There are currently two. You can read the **Server Usage** to see the available options.

### `BetterMarketplace.client.connect`
**connect** lets you connect a Text GuiObject to update whenever stocks update. For example, you could have a TextLabel always show the amount of a certain stock using **connect**, or have an event happen when someone buys an item.
 * `connect(Object: TextLabel|TextButton, Text: string, StockName: string, Callback: (number) -> ()?)`
 * **Object** -> Has to be either a TextLabel or a TextButton, as other GuiObjects do not have Text.
 * **Text** -> The unformatted string you want it to update to. For example, putting in *"Current Stock: %s"* will make it show the actual number on a Stock Update (i.e., *"Current Stock: 100"*).
 * **StockName** -> This is the name of the Item. So for example, if you want to keep track of the DevProduct named "product"'s Stock, you would just put `BetterMarketplace.client.connect(..., ..., "product", ...)`
 * **Callback** -> This function fires whenever it recieves a Stock Update for the Item. It also has a `Stock` parameter that you can use, which is why the type is `(number) -> ()`.
## Settings
Located in `BetterMarketplace/@settings`
 * **PassTracker** -> A string directory value of where gamepass data should be stored. It can be formatted by using forward slashes like so: *"Player/Passes"*. If the path does not already exist, it will be created. If you would not to use this, you can set this to **nil**.
 * **UseDS** -> Short for *"Use DataStores"*. When enabled, GamePass data will be saved to the DataStores so it can be easily used to load items inside of the **PassTracker**. When disabled, it will check ownership using **UserOwnsGamePassAsync** each time instead.
 * **StockUpdates** -> An interval that determines how often stocks will be automatically updated. To remove auto-updates, set this to **-1**. The other times where stocks are updated are during purchases and before purchases (at the start of the **prompt** function)
## Items
Located in `BetterMarketplace/@items`
 * You can create new Items by following this format:

     * ```luau
       [ProductName] = {
			Id = [ProductId],
			Type = Enum.InfoType.[Product || GamePass],
			Callback = function(Player: Player)
				--- [Anything you want here! (or nothing)]
			end,
       }
      
* Anything in [brackets] are things you can replace. Do not keep the brackets.
* **Id** -> Self-explanatory. Just put the ID of your item here.
* **Type** -> Also pretty simple. If your item is a GamePass, put `Enum.InfoType.GamePass`. If it isn't, put `Enum.InfoType.Product`.
* **Callback** -> A function that executes whenever the player buys the item. It also has a Player parameter that you can use.
* **Stock** *(optional)* -> Stock lets you put only a limited amount of copies of an item out. Every time someone buys an item, the number goes down.
