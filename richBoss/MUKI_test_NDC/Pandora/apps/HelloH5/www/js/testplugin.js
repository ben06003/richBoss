document.addEventListener( "plusready",  function()
{
    var _BARCODE = 'plugintest',
		B = window.plus.bridge;
    var plugintest = 
    {
    	PluginTestFunction : function (Argus1, Argus2, Argus3, Argus4, successCallback, errorCallback ) 
		{
			var success = typeof successCallback !== 'function' ? null : function(args) 
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code) 
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);

			return B.exec(_BARCODE, "PluginTestFunction", [callbackID, Argus1, Argus2, Argus3, Argus4]);
		},                          
        PluginTestFunctionSync : function (Argus1, Argus2, Argus3, Argus4) 
        {                                	
            return B.execSync(_BARCODE, "PluginTestFunctionSync", [Argus1, Argus2, Argus3, Argus4]);
        },
                          
        PluginTestFunctionArrayArgu : function (Argus)
        {                                	
            return B.exec(_BARCODE, "PluginTestFunctionArrayArgu", [Argus]);
        },
        AuthenticateUser: function(successCallback, errorCallback)
        {
                          var success = typeof successCallback !== 'function' ? null : function(args)
                          {
                          successCallback(args);
                          },
                          fail = typeof errorCallback !== 'function' ? null : function(code)
                          {
                          errorCallback(code);
                          };
                          callbackID = B.callbackId(success, fail);
                          return B.exec(_BARCODE,"AuthenticateUser", [callbackID]);
        }
    };
    window.plus.plugintest = plugintest;
}, true );
