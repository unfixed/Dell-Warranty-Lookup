from asset import *

def import_csv(path_to_file):
    csv_file = open(path_to_file, "r")
    values = []
    for line in csv_file:
        item = line.split(",")
        item[-1] = item[-1][:-1]        
        values.append(tuple(item))
    return values

def parse_csv(imported_data,path_to_file):
    new_data = []
    for item in imported_data:
        print("retreiving information for %s..." %item[0])
        new_data += Asset(item[0],item[1],item[2],item[3]).print_csv()
    create_csv(new_data,path_to_file)
    return

def create_csv(retrieved_data,path_to_file):
    new_csv = open(path_to_file[:-4]+'_parsed.csv', "w")
    new_csv.write('name,model,service_tag,ship date,warranty end date,user,dept\n')
    for line in retrieved_data:
        new_csv.write(line)
    new_csv.close()
    return
parse_csv(import_csv("sample_data.csv"), "sample_data.csv")
