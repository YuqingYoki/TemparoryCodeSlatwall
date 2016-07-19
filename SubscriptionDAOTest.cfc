component extends="Slatwall.meta.tests.unit.SlatwallUnitTestBase" {


	public void function setUp() {
		super.setup();
		
		variables.dao = request.slatwallScope.getDAO("accountDAO");
	}

	private any function createMockSku(string productID = "") {
		var skuData = {
			skuID = ""
		};
		if(len(arguments.productID)) {
			skuData.product = {
				productID = arguments.productID
			};
		}
		return createPersistedTestEntity('Sku', skuData);
	}
	
	private any function createMockProduct() {
		var productData = {
			productID = ""
		};
		return createPersistedTestEntity('Product', productData);
	}

	public void function getUnusedProductSubscriptionTermsTest() {
		var mockProduct = createMockProduct();
		
		var mockSku = createMockSku(mockProduct.getProductID());

		var subscriptionTermDataWithSKU = {
			subscriptionTermID = "",
			subscriptionTermName = "MockSTNameUsed",
			skus = [
				{
					skuID = mockSku.getSkuID()
				}
			]
		};
		var mockSubscriptionTermUsed = createPersistedTestEntity('SubscriptionTerm', subscriptionTermDataWithSKU);

		var subscriptionTermData = {
			subscriptionTermID = "",
			subscriptionTermName = "MockSTNameUnused"
		};
		var mockSubscriptionTerm = createPersistedTestEntity('SubscriptionTerm', subscriptionTermData);
		
		
		var ExpectStructUnused = {//struct of the unused mockSubscriptionTerm
			name = mockSubscriptionTerm.getSubscriptionTermName(),
			value = mockSubscriptionTerm.getSubscriptionTermID()
		};
		var ExpectStructUsedByMockProduct = {//struct of the used one
			name = mockSubscriptionTermUsed.getSubscriptionTermName(),
			value = mockSubscriptionTermUsed.getSubscriptionTermID()
		};
		//Testing the Not In on SKU
		var resultSkuFilter = mockSubscriptionTerm.getService('subscriptionService').getUnusedProductSubscriptionTerms( mockProduct.getProductID() );
		assertTrue(arrayFind(resultSkuFilter, ExpectStructUsedByMockProduct) == 0);
		assertTrue(arrayFind(resultSkuFilter, ExpectStructUnused) != 0);
		
		//Testing the wrong argument
		var resultWrongProduct = mockSubscriptionTerm.getService('subscriptionService').getUnusedProductSubscriptionTerms( "SameFakeProductID" );
		assertTrue(arrayFind(resultWrongProduct, ExpectStructUsedByMockProduct) != 0);
		assertTrue(arrayFind(resultWrongProduct, ExpectStructUnused) != 0);
		
		//Testing the where condition on Product: 
		var mockSkuNoProduct = createMockSku();
		
		var subscriptionTermDataNoProduct = {
			subscriptionTermID = "",
			subscriptionTermName = "MockSTNoProduct"
		};
		var mockSubscriptionTermNoProduct = createPersistedTestEntity('SubscriptionTerm', subscriptionTermData);
		
		var expectedStructNoProductRelated = {//struct of the ST with no product related
			name = mockSubscriptionTermNoProduct.getSubscriptionTermName(),
			value = mockSubscriptionTermNoProduct.getSubscriptionTermID()
		};
		var resultProductFilter = mockSubscriptionTerm.getService('subscriptionService').getUnusedProductSubscriptionTerms( mockProduct.getProductID() );
		assertTrue(arrayFind(resultProductFilter, expectedStructNoProductRelated) != 0);
	}	
}