
#Need Filename - asset.py
class asset():
    
    def __init__(self,name,service_tag,user,dept):

        def GetAssetInformation(service_tag):
            from suds.client import Client
            import uuid
            client = Client("http://xserv.dell.com/services/assetservice.asmx?WSDL")
            return client.service.GetAssetInformation(uuid.uuid1(), "dell_asset_lookup", service_tag)

        asset_info = GetAssetInformation(service_tag)
        self.name = name.upper()
        self.model = str(asset_info.Asset[0][0][4]) + ' ' + str(asset_info.Asset[0][0][5])
        self.service_tag = asset_info.Asset[0][0][0]
        self.shipped_date = str(asset_info.Asset[0][0][6])

        
        self.warranty_end_date =  ''# asset_info.Asset[0][0][0]

        
        self.user = user
        self.dept = dept



    def csv_line(self):
        return ('"%s","%s","%s","%s","%s","%s"' %(self.name,self.model,self.service_tag,self.shipped_date,self.user,self.dept))

    # method used for testing purposes.
    def print_asset(self):
        print(self.name,self.model,self.service_tag,self.shipped_date,self.user,self.dept)
        return








#Need Filename - import_csv.py
def import_csv(path_to_file):
    return

def parse_csv(data):
    #split values here

    asset()
    return












item = Asset('WS00001','chg94q1','agondal','OFFICE OF BUDGET PLANNING AND ANALYSIS')
