import haxe.macro.Context;
import haxe.macro.Expr;

class Web3SetupMacro{
	public static function autoBuild():Array<Field> {
		var classType = Context.getLocalClass().get();
		var typePath = {
			name:classType.name,
			pack:classType.pack
		};

		var fields = Context.getBuildFields();

		var fieldsMap = new Map();

		for(field in fields){
			fieldsMap[field.name] = field;
		}

		if(!fieldsMap.exists("onWeb3Ready")){
			//TODO check signature
			Context.error(""+typePath.name + "  needs  a method called onWeb3Ready that accept a web3 instance", Context.currentPos());
		}
		if(!fieldsMap.exists("onWeb3Error")){
			//TODO check signature	
			Context.error(""+typePath.name + "  needs  a method called onWeb3Error that accept a error parameter", Context.currentPos());
		}

	    fields.push({
	      name:  "main",
	      access:  [Access.APublic, Access.AStatic],
	      kind: FieldType.FFun({
	      	args:[],
	      	expr:macro {
	      		new $typePath();	
	      	},
	      	params:null,
	      	ret:null
	      }), 
	      pos: Context.currentPos()
	    });

	    fields.push({
	      name:  "new",
	      access:  [Access.APublic],
	      kind: FieldType.FFun({
	      	args:[],
	      	expr:macro {
	      		super();	
	      	},
	      	params:null,
	      	ret:null
	      }), 
	      pos: Context.currentPos()
	    });

	    fields.push({
	    	name:"_execute",
	    	access:[Access.AOverride],
	    	kind : FieldType.FFun({
	    		args:[{
	    			name:"web3",
	    			type:macro:web3.Web3
	    		}],
	    		expr:macro {
	    			onWeb3Ready(web3);
	    		},
	    		params:null,
	    		ret:null
	    	}),
	    	pos : Context.currentPos()
	    });

	    fields.push({
	    	name:"_error",
	    	access:[Access.AOverride],
	    	kind : FieldType.FFun({
	    		args:[{
	    			name:"error",
	    			type:macro:Dynamic
	    		}],
	    		expr:macro {
	    			onWeb3Error(error);
	    		},
	    		params:null,
	    		ret:null
	    	}),
	    	pos : Context.currentPos()
	    });
	    
	    return fields;
	 }
}