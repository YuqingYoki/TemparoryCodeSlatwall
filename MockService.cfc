/*

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Linking this program statically or dynamically with other modules is
    making a combined work based on this program.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.

    As a special exception, the copyright holders of this program give you
    permission to combine this program with independent modules and your
    custom code, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting program under terms
    of your choice, provided that you follow these specific guidelines:

	- You also meet the terms and conditions of the license of each
	  independent module
	- You must not alter the default display of the Slatwall name or logo from
	  any part of the application
	- Your custom code must not alter or create any files inside Slatwall,
	  except in the following directories:
		/integrationServices/

	You may copy and distribute the modified version of this program that meets
	the above guidelines as a combined work under the terms of GPL for this program,
	provided that you include the source code of that other code when and as the
	GNU GPL requires distribution of source code.

    If you modify this program, you may extend this exception to your version
    of the program, but you are not obligated to do so.

Notes:

*/
component extends="Slatwall.meta.tests.unit.SlatwallUnitTestBase" hb_mockService="OrderMockService"{
	
	public void function init(){
		
	}
	
	public void function verifyRel(required any entityObject, required string propertyName) {
		var thisProperty = request.slatwallScope.getService("hibachiService").
							getPropertyByEntityNameAndPropertyName(arguments.entityObject.getClassName(), arguments.propertyName);
		var errorMsg = '#arguments.entityObject.getClassName()#.#arguments.propertyName# ';
		
		if(!structKeyExists(thisProperty, "cfc") && !structKeyExists(thisProperty, 'fieldType')) {
			throw(errorMsg & "doesn't have a CFC & FieldType relationship. VerifyRel stops");
		}
		
		if(thisProperty.fieldType == 'Many-to-Many' || thisProperty.fieldType == 'One-to-Many') {
			var hasRel = invoke(arguments.entityObject, 'has'&thisProperty.singularname);
			if(hasRel) {
				throw(errorMsg & 'hasXXX() returns FALSE.');
			}
			
			var getArray = invoke(arguments.entityObject, 'get'&thisProperty.name);
			if(arrayLen(getArray) >= 1) {
				throw(errorMsg & 'getXXX() length < 1.');
			}
			
			var getID = getArray[1].invokeMethod('get'&thisProperty.cfc&'ID');
			if(isNull(getID)) {
				throw(errorMsg & 'getXXXID() returns empty.');
			}
		} else {
			if(!isNull(invoke(arguments.entityObject, methodName))){
				throw('Association verification fails: #entityObject.getClassName()#.#methodName#() returns empty.');
			}

		}
	}
	
	public struct function createBasicMockData(required string entityName, struct arguData, array whitelist ) {
		var entityData = {};
		var outputReminder = 'createBasicMockEntity all properties with TIMESTAMP types have been set to NULL! ';
		
		for(var property in request.slatwallScope.getService('HibachiService').getPropertiesByEntityName(arguments.entityName)){
			
			//If arguData has it, save it.
			if(structKeyExists(arguments.arguData, property.name)) {
				entityData[property.name] = arguData[property.name];
				if (arrayContains(whitelist, property.name)) {
					writeOutput('#entityname#.#properety.name# is in whitelist but been valued <br>');
				}
			//if property was not defined OR hb_populateTestData=true or not defined OR in whitelist, then make generic mock data
			} else if(!arrayContains(whitelist, property.name)) {
				if(structKeyExists(property,'fieldType') && property) {
					if(property.fieldType == 'id') {
						entityData[property.name] = "";
					}
				} else if(structKeyExists(property,'ormtype')){
					if(property.ormtype == 'string') {
						if(structKeyExists(property, 'length')) {
							entityData[property.name] = generateRandomString(property.length, property.length);
						} else {
							entityData[property.name] = generateRandomString(2, 5);
						}						
					}
					if(property.ormType == 'timestamp') {
						entityData[property.name] = NULL;
					}
				}	
			}
						
		}
		writeOutput(outputReminder);
		writeDump(entityData);
		return entityData;	
	}
	
	/**
	*  Only works for many-to-one and one-to-one associtions
	*/
	public any function createToOneAssnOnMissingObject(required any entityObject) {
		
		//Verify the cfc value
		var Property = request.slatwallScope.getService("hibachiService").getPropertyByEntityNameAndPropertyName('#entityObject.getClassName()#', arguments.propertyName);
		if(!structKeyExists(Property, "cfc")) {
			throw('#entityObject.getClassName()#.#propertyName# property does not have cfc value');
		}
		var assnEntityName = Property.cfc;
		
		if (assnEntityName == 'type') {
			arguments.structValueEntity = returnDefaultTypeByPropertyName(arguments.propertyName);
		} else {
			var createEntityMethodName = "createMock" & assnEntityName;
			if(structKeyExists(this,'#createEntityMethodName#')) {//Yuqing: calls functions in other files
				var createEntityMethod = this[createEntityMethodName];
				var tempEntity = createEntityMethod();
			} else {
				request.debug("On missing entity");
				var tempEntity = createSimpleMockEntityByEntityName(assnEntityName);//Yuqing: calls functions in other files
			}
			arguments.structValueEntity = tempEntity;
		}
		
		//Set Association
		var methodName = 'set#arguments.propertyName#';
		arguments.entityObject.invokeMethod(methodName=methodName,methodArguments = { 1=arguments.structValueEntity });
		
		verifyRel(arguments.entityObject, arguments.propertyName);
		return arguments.entityObject;
		
	}
	/**
	*  Only works for many-to-one and one-to-one associtions with related entity passed in
	*/
	public any function createToOneAssociation(required any entityObject, required string propertyName, required any relatedEntity) {
		
		//Verify the cfc value
		var Property = request.slatwallScope.getService("hibachiService").getPropertyByEntityNameAndPropertyName('#entityObject.getClassName()#', arguments.propertyName);
		if(!structKeyExists(Property, "cfc")) {
			throw('#entityObject.getClassName()#.#propertyName# property does not have cfc value');
		}
		var assnEntityName = Property.cfc;
		
		//Set Association
		var methodName = 'set#arguments.propertyName#';
		arguments.entityObject.invokeMethod(methodName=methodName,methodArguments = { 1=arguments.structValueEntity });
		
		verifyRel(arguments.entityObject, arguments.propertyName);
		return arguments.entityObject;	
	}
	
	
	
	/**
	*  Only works on many-to-many and one-to-many associtions
	*/
	public any function createToManyAssnOnMissingObject(required any entityObject) {
		
		//Verify the cfc value
		var thisProperty = request.slatwallScope.getService("hibachiService").getPropertyByEntityNameAndPropertyName('#entityObject.getClassName()#', arguments.propertyName);
		if(!structKeyExists(thisProperty, "cfc")) {
			throw('#entityObject.getClassName()#.#propertyName# property does not have cfc value');
		}
		var assnEntityName = thisProperty.cfc;
		
		var createEntityMethodName = "createMock" & assnEntityName;
		if(structKeyExists(this,'#createEntityMethodName#')) {
			var createEntityMethod = this[createEntityMethodName];
			var tempEntity = createEntityMethod();
		} else {
			var tempEntity = createSimpleMockEntityByEntityName(assnEntityName);
		}			
		arguments.propertyValue[1] = tempEntity;

		//Set Association, propertyValue is an array of entities
		for (var oneValue in arguments.propertyValue) {
			var methodName = 'add#thisProperty.singularname#';
			arguments.entityObject.invokeMethod(methodName = methodName, methodArguments = {1 = oneValue});
		}
		
		verifyRel(arguments.entityObject, arguments.propertyName);
		return arguments.entityObject;
		
	}
		
	/**
	*  Only works on many-to-many and one-to-many associtions with array of entites passed
	*/
	public any function createToManyAssociation(required any entityObject, required string propertyName, required array propertyValue=[]) {
		
		//Verify the cfc value
		var thisProperty = request.slatwallScope.getService("hibachiService").getPropertyByEntityNameAndPropertyName('#arguments.entityObject.getClassName()#', arguments.propertyName);
		if(!structKeyExists(thisProperty, "cfc")) {
			throw('#entityObject.getClassName()#.#propertyName# property does not have cfc value');
		}
		var assnEntityName = thisProperty.cfc;
		
		//Set Association, propertyValue is an array of entities
		for (var oneValue in arguments.propertyValue) {
			var methodName = 'add#thisProperty.singularname#';
			arguments.entityObject.invokeMethod(methodName = methodName, methodArguments = {1 = oneValue});
		}
		
		verifyRel(arguments.entityObject, arguments.propertyName);
		return arguments.entityObject;
		
	}
	
	public any function returnTypeBySystemCode(required any entityObject, required string propertyName, required string sysCode) {
		var typeList = entityObject.getPropertyOptionsSmartList(arguments.propertyName).getRecords(refresh = true);
		
		for (var type in typeList) {
			if (type.getSystemCode == arguments.sysCode) {
				return type;
			} else {
				throw("The systemCode cannot be found in the type options");
			}
		}
	}
	

}
