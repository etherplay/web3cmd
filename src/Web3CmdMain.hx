
import web3.Web3;
import web3.Web3Util;

class Web3CmdMain extends Web3Setup{

	function onWeb3Ready(web3 : Web3){
		
		Sys.println('account : $account');

		var args = Sys.args();
		if(args.length < 2){
			var gasPriceInEth : Ether = gasPrice;
			Sys.println('networkID : $networkID with gasPrice : $gasPriceInEth ETH');
		}else if(args[1].toLowerCase() == "eth"){
			if(args.length < 3){
				Sys.println('need to specify command');
			}else{
				if(!Reflect.hasField(web3.eth,args[2])){
					Sys.println('web3.eth.'+args[2] + ' does not exists');
				}else{
					var promise : js.Promise<Dynamic> = Reflect.callMethod(web3.eth,Reflect.field(web3.eth,args[2]),args.slice(3) ); //TODO pass argument
					promise
					.then(function(result){
						var jsonResult = haxe.Json.stringify(result);
						Sys.print('result : $jsonResult');
						if(args[2]=="getBalance"){
							Sys.println(' (' + Utils.fromWei(result,'ether') + " Ether)");
						}else{
							Sys.println('');
						}
					})
					.catchError(reportError);	
				}
			}
			
		// }else if(args[1].toLowerCase() == "deploycontract"){
		// 	if(args.length < 3){
		// 		Sys.println('need to specify contract code file');
		// 	}else{
		// 		var code = js.node.Fs.readFileSync(args[2]).toString();
		// 		web3.eth.sendTransaction({gas:4000000,gasPrice:gasPrice,from:account},function(error,txHash){
		// 			if(error != null){
		// 				reportError(error);
		// 			}else{
		// 				Web3Util.waitForTransactionReceipt(web3,txHash,function(error,txHash,receipt){
		// 					if(error != null){
		// 						reportError(error);
		// 					}else{
		// 						if(receipt == null){
		// 							reportError("receipt is null");
		// 						}else{
		// 							if(receipt.contractAddress == null){
		// 								reportError("contractAddress is null");
		// 							}else{
		// 								Sys.println("contract address : " + receipt.contractAddress);
		// 								trace("writing to " + code_filename + " ...");
		// 								js.node.Fs.writeFileSync(code_filename, haxe.Json.stringify(contractBytecode)); 
		// 							}
		// 						}
		// 					}
							
		// 				});
		// 			}
		// 		});
		// 	}
		}else if(args[1].toLowerCase() == "deploycontract"){
			if(args.length < 3){
				Sys.println('need to specify contract info file');
			}else{
				var contractInfoContent = js.node.Fs.readFileSync(args[2]).toString();
				var contractInfo : {name:String,contractInfo:haxe.DynamicAccess<Dynamic>} = haxe.Json.parse(contractInfoContent);
				var contractABIString = contractInfo.contractInfo["interface"];
				var contractABI  = haxe.Json.parse(contractABIString);
				var contractBytecode = "0x"+contractInfo.contractInfo["bytecode"]; 
				// trace(contractBytecode);
				web3.eth.sendTransaction({gas:4500000,gasPrice:gasPrice,from:account,data:contractBytecode},function(error,txHash){
					if(error != null){
						reportError(error);
					}else{
						Sys.println('txHash : $txHash');
						Web3Util.waitForTransactionReceipt(web3,txHash,function(error,txHash,receipt){
							if(error != null){
								reportError(error);
							}else{
								Sys.println('txHash : $txHash');
								if(receipt == null){
									reportError("receipt is null");
								}else{
									if(receipt.contractAddress == null){
										reportError("contractAddress is null");
									}else{
										Sys.println("contract address : " + receipt.contractAddress);
										if (!js.node.Fs.existsSync('deployed_contracts')){
											try{js.node.Fs.mkdirSync('deployed_contracts');}catch(e:Dynamic){}
										}
										var prefix = 'deployed_contracts' +"/"+networkID + "_" + receipt.contractAddress.toLowerCase();
										js.node.Fs.writeFileSync(prefix+".code", contractBytecode); 
										js.node.Fs.writeFileSync(prefix+".abi", contractABIString); 
									}
								}
							}
							
						});
					}
				});
			}
		}else if(args[1].toLowerCase().indexOf("contract@") == 0){
			if(args.length < 3){
				Sys.println('need to specify method');
			}else{
				var method = args[2];
				var contractAddress = args[1].toLowerCase().split("@")[1];
				Sys.println('TODO $contractAddress $method');
				//TODO need abi
				// var promise : js.Promise<Dynamic> = Reflect.callMethod(web3.eth,Reflect.field(web3.eth,args[2]),args.slice(3) ); //TODO pass argument
				// promise
				// .then(function(result){
				// 	var jsonResult = haxe.Json.stringify(result);
				// 	Sys.println('result : $jsonResult');
				// })
				// .catchError(function(error){
				// 	Sys.println('ERROR : $error');
				// });
			}
			
		}else{
			Sys.println('unknown command');
		}

	}

	function onWeb3Error(error : Dynamic){
		reportError(error);
	}
}