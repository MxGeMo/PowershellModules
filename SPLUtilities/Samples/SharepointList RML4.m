let
    Source = SharePoint.Tables("https://nokia.sharepoint.com/sites/ProcurementIntelligence/MasterData/RM", [ApiVersion = 15]),
    SharepointList = Source{[Id="75a9b08c-1380-4b7c-ac11-ddd8e04860e5"]}[Items],
    SelectedFields = Table.SelectColumns(SharepointList,{
		"ID",
		"Title",

		"Aera",
		"Grp",
		"Cat",
		"Base",

		/*"OData_RML3",*/
		"OData_RML3Id",

		"Key",
		"SubID",
		"Commcode",
		"Name",
		"Sub Category",

		"Sub Category Manager",
		"Sub Category ManagerId",
		/*"Sub Category ManagerStringId",*/

		/*"Sub Category Members",*/
		"Sub Category MembersId",
		/*"Sub Category MembersStringId",*/

		/*"NAM North America",*/
		"NAM North AmericaId",
		/*"NAM North AmericaStringId",*/

		/*"LAT Latin America",*/
		"LAT Latin AmericaId",
		/*"LAT Latin AmericaStringId",*/

		/*"CHI Greater China",*/
		"CHI Greater ChinaId",
		/*"CHI Greater ChinaStringId",*/

		/*"IND India",*/
		"IND IndiaId",
		/*"IND IndiaStringId",*/

		/*"APA - Asia_x00",*/
		"APA - Asia_x00Id",
		/*"APA - Asia_x00StringId",*/

		/*"EUR - Europe",*/
		"EUR - EuropeId",
		/*"EUR - EuropeStringId",*/

		/*"MEA - East_x00",*/
		"MEA - East_x00Id",
		/*"MEA - East_x00StringId",*/

		"CC",

		"Created",
		"Author",
		"AuthorId",
		"Modified",
		"Editor",
		"EditorId",
		"GUID"})
in
    SelectedFields