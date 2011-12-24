#Seperate File - Filename - asset.py
class Asset():
    
    def __init__(self,service_tag,name,user,dept):

        def GetAssetInformation(service_tag):
            from suds.client import Client
            import uuid
            client = Client("http://xserv.dell.com/services/assetservice.asmx?WSDL")
            return client.service.GetAssetInformation(uuid.uuid1(), "dell_asset_lookup", service_tag)

        def warranty_end_date(asset_info):
            dates = []
            for n in range(len(asset_info[0][0][1][0])):
                dates.append(asset_info[0][0][1][0][n][4].date())
            return max(dates)

        asset_info = GetAssetInformation(service_tag)
        self.name = name.upper()
        self.model = str(asset_info.Asset[0][0][4])
        self.service_tag = str(asset_info.Asset[0][0][0])
        self.shipped_date = str(asset_info.Asset[0][0][6].date())
        self.warranty_end_date =  str(warranty_end_date(asset_info))
        self.user = user
        self.dept = dept

    def print_csv(self):
        return str('%s,%s,%s,%s,%s,%s,%s\n' %(self.name,self.model,self.service_tag,self.shipped_date,self.warranty_end_date,self.user,self.dept))
