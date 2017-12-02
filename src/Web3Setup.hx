import web3.Web3;
import web3.Web3Util;


import providerengine.ProviderEngine;
import providerengine.RpcSubprovider;
import providerengine.HookedWalletSubprovider;
import providerengine.HookedWalletEthTxSubprovider;
import providerengine.NonceTrackerSubprovider;

typedef Config = {
	nodeUrl:String,
	maxLatestBlockTimeDelay:Float
}

typedef SetupResult = {
	var web3 : Web3;
	var account : Address;
	var nodeUrl : String;
	var maxLatestBlockTimeDelay : Float;
}

@:autoBuild(Web3SetupMacro.autoBuild())
class Web3Setup{

	var web3 : Web3;
	var account : Address;
	var nodeUrl : String; 
	var gasPrice : Wei;
	var networkID : String; 
	var latestBlockNumber : Float;
	var latestBlockTimestamp : Float;

	function reportError(error : Error){
		Sys.println('ERROR : $error');
	}

	function new(){
		var args = Sys.args();
		if(args.length < 1){
			trace("need at least 1 argument : cmd <conf.json>");	
			return;
		}
		var setup = setupWeb3(args[0]);
		web3 = setup.web3;
		account = setup.account;
		nodeUrl = setup.nodeUrl;

		web3.eth.net.getId().then(function(networkID){
			this.networkID = networkID;
			web3.eth.getGasPrice().then(function(gasPrice){
				this.gasPrice = gasPrice;
				web3.eth.getBlock(Latest).then(function(block){
					
					this.latestBlockNumber = block.number;
					this.latestBlockTimestamp = block.timestamp;

					if(setup.maxLatestBlockTimeDelay > 0 && Date.now().getTime() - latestBlockTimestamp > setup.maxLatestBlockTimeDelay){
						_error("latest block is more than " +setup.maxLatestBlockTimeDelay+"s old");
					}else{
						_execute(web3);	
					}
					
				}).catchError(_error);
			}).catchError(_error);
		}).catchError(_error);
	}


	function _error(error : Dynamic){

	}

	function _execute(web3 : Web3){

	}


	static public function setupWeb3(confFileName : String) : SetupResult{
		var setup :SetupResult = {
			web3:null,
			account:null,
			nodeUrl:null,
			maxLatestBlockTimeDelay:0
		};

		var conf : Config = haxe.Json.parse(js.node.Fs.readFileSync(confFileName).toString());

		setup.nodeUrl = conf.nodeUrl;
		setup.maxLatestBlockTimeDelay = conf.maxLatestBlockTimeDelay;
		
		var privateKey : String = null;
		try{
			privateKey = js.node.Fs.readFileSync(".pk").toString(); //TODO look up the chain of folders? + try at home folder first
		}catch(e : Dynamic){
			privateKey = null;
		}

		var hasPrivateKey = privateKey != null && privateKey != "";



		var web3 = new Web3();
		setup.web3 = web3; 


		if(hasPrivateKey){
			var account = web3.eth.accounts.privateKeyToAccount("0x"+privateKey);
			setup.account = account.address;

			var engine = new ProviderEngine();

			// engine.addProvider(new NonceTrackerSubprovider());

			
			engine.addProvider(new HookedWalletEthTxSubprovider({
				getAccounts: function(cb){ cb(null,[setup.account]); },
				getPrivateKey: function(address, cb){
					cb(null, untyped js.node.buffer.Buffer.from(privateKey,"hex"));
					// var keyObject = Keythereum.importFromFile(account, "../testnet");
					// 	var privateKey = Keythereum.recover("fake",keyObject);
					// 	trace(privateKey);
					// 	cb(null, privateKey);
					}
			}));

			
			// data source
			engine.addProvider(new RpcSubprovider({
				rpcUrl: setup.nodeUrl
			}));

			// // log new blocks
			// engine.on('block', function(block : Dynamic){
			// 	js.Node.console.log('================================');
			// 	js.Node.console.log('BLOCK CHANGED:', '#'+block.number.toString('hex'), '0x'+block.hash.toString('hex'));
			// 	js.Node.console.log('================================');
			// });

			// network connectivity error
			engine.on('error', function(err : Dynamic){
				// report connectivity errors
				js.Node.console.error(err.stack);
			});

			web3.setProvider(engine);
			engine.start();
		}else{
			web3.setProvider(new web3.providers.HttpProvider(setup.nodeUrl));
		}

		return setup;
	}
}