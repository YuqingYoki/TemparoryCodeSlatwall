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
	public void function setup(){
		super.setup();
	}
	
	public void function verifyRelTest() {
		
	}
	
	
	public any function createBasicMockEntityTest(required string entityName, struct arguData, array whitelist ) {
		
	}

	public any function createToOneAssociationTest() {
		var orderData = {
			order = ''
		};
		var mockOrder = createPersistedTestEntity('Order', orderData);
		
		//Testing when arguments.structValueEntity is empty
		var resultMockOrderNoValue = variables.mockService.createToOneAssociation(mockOrder, 'account');
		assertTrue(resultMockOrderNoValue.hasAccount(), 'Order.account failed been associated without entity value passed');
		
		//Testing when arguments.structValueEntity  exists
		var accountData = {
			accountID = ''
		};
		var mockAccount = createPersistedTestEntity('account', accountData);
		
		var resultMockOrderWithValue = variables.mockService.createToOneAssociation(mockOrder, 'account', mockAccount);
		assertEquals(mockAccount.getAccountID(), resultMockOrderNoValue.getAccount().getAccountID(), 
					'Order.account failed been associated when argument.structValueEntity existed');	
	}
	
	public any function createToManyAssociationTest() {
		var orderData = {
			order = ''
		};
		var mockOrder = createPersistedTestEntity('Order', orderData);
		
		//Testing when arguments.structValueEntity is empty
		var resultMockOrderNoValue = variables.mockService.createToManyAssociation(mockOrder, 'orderPayments');
		request.debug(resultMockOrderNoValue.getOrderPayments()[1].getOrderPaymentID());
		assertFalse(isNull(resultMockOrderNoValue.getOrderPayments()[1].getOrderPaymentID()), 'Order.orderPayment failed been associated without entity value passed');
		
		//Testing when arguments.structValueEntity  exists
		var orderPaymentData1 = {
			orderPaymentID = ''
		};
		var mockOrderPayment1 = createPersistedTestEntity('orderPayment', orderPaymentData1);
		
		var orderPaymentData2 = {
			orderPaymentID = ''
		};
		var mockOrderPayment2 = createPersistedTestEntity('orderPayment', orderPaymentData2);
		
		var mockOrderPaymentArray = [mockOrderPayment1, mockOrderPayment2];
		
		request.debug(mockOrderPayment1.getORderPaymentID());
		request.debug(mockOrderPayment2.getOrderPaymentID());
		
		var resultMockOrderWithValue = variables.mockService.createToManyAssociation(mockOrder, 'orderPayments', mockOrderPaymentArray);
		request.debug(arrayLen(resultMockOrderNoValue.getOrderPayments()));
		request.debug(resultMockOrderNoValue.getOrderPayments()[1].getOrderPaymentID());
		request.debug(resultMockOrderNoValue.getOrderPayments()[2].getOrderPaymentID());
		request.debug(resultMockOrderNoValue.getOrderPayments()[3].getOrderPaymentID());
		
		
		assertTrue(arrayLen(resultMockOrderNoValue.getOrderPayments()) == 2, 
					'Order.account failed been associated when argument.structValueEntity existed');		
	}
	
	public any function returnTypeByID(required string typeID) {
		
	}
	
	public any function returnTypeBySystemCode(required any entityObject, required string propertyName, required string sysCode) {
		
	}
	
	
	public any function createMockMissingEntity(required string entityName) {
	
	}
	
}
