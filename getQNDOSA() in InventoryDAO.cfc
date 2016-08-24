// Quantity not delivered on stock adjustment
		public array function getQNDOSA(required string productID, string productRemoteID) {
			
			var params = {productID=arguments.productID};
			var hql = "SELECT NEW MAP(
					coalesce( 
						(
							SELECT sum(stockAdjustmentItem.quantity)
							FROM SlatwallStockAdjustmentItem stockAdjustmentItem
							LEFT JOIN
								stockAdjustmentItem.fromStock fromStock
							WHERE
								stockAdjustmentItem.stockAdjustment.stockAdjustmentStatusType.systemCode != 'sastClosed'
							  AND
								fromStock.sku.product.productID = :productID
						), 0 
					) 
					- coalesce( sum(stockAdjustmentDeliveryItem.quantity), 0 ) as QNDOSA, 
						fromStock.sku.skuID as skuID, 
						fromStock.stockID as stockID, 
						location.locationID as locationID, 
						location.locationIDPath as locationIDPath)
					FROM
						SlatwallStockAdjustmentItem stockAdjustmentItem
					  LEFT JOIN
					  	stockAdjustmentItem.stockAdjustmentDeliveryItems stockAdjustmentDeliveryItem
					  LEFT JOIN
					  	stockAdjustmentItem.fromStock fromStock
					  LEFT JOIN
					  	fromStock.location location
					WHERE
						stockAdjustmentItem.stockAdjustment.stockAdjustmentStatusType.systemCode != 'sastClosed'
					  AND
						fromStock.sku.product.productID = :productID
					GROUP BY
						fromStock.sku.skuID,
						fromStock.stockID,
						location.locationID,
						location.locationIDPath";
			
			return ormExecuteQuery(hql, params);
		}