CREATE CLUSTERED INDEX CL_IndexIngredientName -- cluster
ON [dbo].[Ingredient]([name])

CREATE INDEX NCL_IndexIngredientPurchaseCost -- non-cluster
ON [dbo].[Ingredient]([purchase_cost])

CREATE INDEX NCL_Index_Ingredient_DateOfDelivery_InStock -- compound
ON [dbo].[Ingredient]([in_stock], [date_of_delivery])

CREATE INDEX NCL_Index_Covering_Ingredient -- covering
ON [dbo].[Ingredient]([purchase_cost])
INCLUDE([name], [in_stock])

CREATE UNIQUE INDEX NCL_Index_Unique_Ingredient_Name -- unique
ON [dbo].[Ingredient]([name], [purchase_cost])

CREATE INDEX NCL_Index_IncludedColumnsIngredient -- included columns
ON [dbo].[Ingredient]([in_stock])
INCLUDE([name], [purchase_cost], [date_of_delivery])

CREATE INDEX NCL_Index_Filtered_Ingredient -- filtered
ON [dbo].[Ingredient]([name], [in_stock])
WHERE [purchase_cost] > 9000