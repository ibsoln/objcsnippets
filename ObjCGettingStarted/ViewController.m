//
//  ViewController.m
//  ObjCGettingStarted
//
//  Created by Brian Voong on 4/7/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

#import "ViewController.h"
#import "Hotel.h"
#import <CouchbaseLite/CouchbaseLite.h>

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray<Hotel *> *hotels;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSMutableDictionary *> *hoteldicts;

//
@end

@implementation ViewController

NSString *cellId = @"cellId";


- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.navigationItem.title = @"Hotels";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
        
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:cellId];

    [self seedDatabase];
    
    [self dontTestQuerySyntaxJson];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hotels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];

    Hotel *hotel = self.hotels[indexPath.row];

    cell.textLabel.text = hotel.name;
    cell.textLabel.text = [cell.textLabel.text stringByAppendingString: @", "];
    cell.textLabel.text = [cell.textLabel.text stringByAppendingString: hotel.city];
    ;

    return cell;

}


- (void) fetchDataUsingJson{
    NSLog(@"Fetching JSON Data");
    NSError *error;
    
    NSString *jsonString = @"[\r\n {\r\n   \"id\": 1000,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Ted\",\r\n   \"city\": \"Paris\",\r\n   \"country\": \"France\",\r\n   \"description\": \"Undefined description for Hotel Ted\"\r\n },\r\n {\r\n   \"id\": 1001,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Fred\",\r\n   \"city\": \"London\",\r\n   \"country\": \"England\",\r\n   \"description\": \"Undefined description for Hotel Fred\"\r\n },\r\n {\r\n   \"id\": 1002,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Ned\",\r\n   \"city\": \"Balmain\",\r\n   \"country\": \"Australia\",\r\n   \"description\": \"Undefined description for Hotel Ned\"\r\n },\r\n {\r\n   \"id\": 1003,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Jed\",\r\n   \"city\": \"Montreal\",\r\n   \"country\": \"Canada\",\r\n   \"description\": \"Undefined description for Hotel Jed\"\r\n },\r\n {\r\n   \"id\": 1004,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Red\",\r\n   \"city\": \"Tokyo\",\r\n   \"country\": \"Japan\",\r\n   \"description\": \"Undefined description for Hotel Red\"\r\n },\r\n {\r\n   \"id\": 1005,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Ed\",\r\n   \"city\": \"Athens\",\r\n   \"country\": \"Greece\",\r\n   \"description\": \"Undefined description for Hotel Ed\"\r\n },\r\n {\r\n   \"id\": 1006,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Ged\",\r\n   \"city\": \"Ostende\",\r\n   \"country\": \"Belgium\",\r\n   \"description\": \"Undefined description for Hotel Ged\"\r\n }\r\n]";
    
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSLog(@"Dict %@", dict);
    
    NSArray *hotelsJSON = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"Array %@", hotelsJSON);

    NSMutableArray<Hotel *> *hotels = NSMutableArray.new;
    
    for (NSDictionary *hotelData in hotelsJSON) {
        Hotel *thisHotel = Hotel.new;
        thisHotel.id = hotelData[@"id"];
        thisHotel.type = hotelData[@"type"];
        thisHotel.name = hotelData[@"name"];
        thisHotel.city = hotelData[@"city"];
        thisHotel.country = hotelData[@"country"];
        thisHotel.descriptive = hotelData[@"description"];
        [hotels addObject:thisHotel];
        NSLog(@"Added - %@",thisHotel);
    }
    self.hotels = hotels;
    
}

- (void) seedDatabase {
    
    NSError *error;

    // remove any preexisting db
    CBLDatabase *dbclear =
        [[CBLDatabase alloc] initWithName:@"hotels" error:&error];
    [dbclear delete:&error ];

    // Create new db
    CBLDatabase *db =
        [[CBLDatabase alloc] initWithName:@"hotels" error:&error];
    
    if (!db) {
        NSLog(@"Cannot open the database: %@", error);
    }
        
    [self fetchDataUsingJson];
    
    CBLMutableDocument *newTask = [[CBLMutableDocument alloc] init];

    for (Hotel* hotel in self.hotels) {
        [newTask setString:hotel.id forKey:@"id"];
        [newTask setString:hotel.type forKey:@"type"];
        [newTask setString:hotel.name forKey:@"name"];
        [newTask setString:hotel.city forKey:@"city"];
        [newTask setString:hotel.country forKey:@"country"];
        [newTask setString:hotel.descriptive forKey:@"description"];
        [db saveDocument:newTask error:&error];
        NSLog(@"%@", newTask.toDictionary);
    }
    
} // end seeddatbase


- (void) dontTestQuerySyntaxJson {

    // tag::query-syntax-all[]
    NSError *error;
    
    CBLDatabase *db = [[CBLDatabase alloc] initWithName:@"hotels" error: &error];

    CBLQuery *listQuery = [CBLQueryBuilder select:@[[CBLQuerySelectResult all]]
                                             from:[CBLQueryDataSource database:db]]; // <.>
        
    // end::query-syntax-all[]
    
    
    // tag::query-access-all[]
        NSMutableArray* matches =
          [[NSMutableArray alloc] init];
          
        CBLQueryResultSet* resultset = [listQuery execute:&error];

        for (CBLQueryResult *result in resultset.allResults) {
            
            // Get result as dictionary
            NSDictionary *match = [result valueAtIndex: 0]; // <.>
            
            // Store dictionary in array
            [matches addObject: match];

            // Use dictionary values
            NSLog(@"id = %@", [match valueForKey:@"id"]); // <.>
            NSLog(@"name = %@", [match valueForKey:@"name"]);
            NSLog(@"type = %@", [match valueForKey:@"type"]);
            NSLog(@"city = %@", [match valueForKey:@"city"]);
            
        } // end for

    // end::query-access-all[]
        
    
    // tag::query-access-json[]
    for (CBLQueryResult *result in [listQuery execute:&error]) {

        // Get result as a JSON string
        NSString *thisJsonString =
                    [[result valueAtIndex:0 ] toJSON]; // <.>

        // Get a Json Object from the Json String
        NSArray *thisJsonObject =
                [NSJSONSerialization JSONObjectWithData:
                 [thisJsonString dataUsingEncoding: NSUTF8StringEncoding]
                       options: NSJSONReadingAllowFragments
                       error: &error]; // <.>
        if (error) {
            NSLog(@"Error in serialization: %@",error);
            return;
        }

        // Get an native Obj-C object from the Json Object
        NSDictionary *hotelJson
                        = [thisJsonObject mutableCopy]; // <.>

        // Populate a custom object from native dictionary
        Hotel *hotelFromJson = Hotel.new;
        NSMutableArray<Hotel *> *hotels = NSMutableArray.new;

        hotelFromJson.id = hotelJson[@"id"];
        hotelFromJson.name = hotelJson[@"name"];
        hotelFromJson.city = hotelJson[@"city"];
        hotelFromJson.country = hotelJson[@"country"];
        hotelFromJson.descriptive = hotelJson[@"description"];

        [hotels addObject:hotelFromJson];

        // Log generated Json and Native objects
        // For demo/example purposes
        NSLog(@"Json Object %@", thisJsonObject);
        NSLog(@"Json String %@", thisJsonString);
        NSLog(@"Native Object: id: %@ name: %@ city: %@ country: %@ descriptive: %@", hotelFromJson.id, hotelFromJson.name, hotelFromJson.city, hotelFromJson.country, hotelFromJson.descriptive);

       }; // end for

    // end::query-access-json[]
    
} // end function

- (void) jsondata {
    
    NSString *json = @"[\r\n {\r\n   \"id\": 1000,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Ted\",\r\n   \"city\": \"Paris\",\r\n   \"country\": \"France\",\r\n   \"description\": \"Undefined description for Hotel Ted\"\r\n },\r\n {\r\n   \"id\": 1001,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Fred\",\r\n   \"city\": \"London\",\r\n   \"country\": \"England\",\r\n   \"description\": \"Undefined description for Hotel Fred\"\r\n },\r\n {\r\n   \"id\": 1002,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Ned\",\r\n   \"city\": \"Balmain\",\r\n   \"country\": \"Australia\",\r\n   \"description\": \"Undefined description for Hotel Ned\"\r\n },\r\n {\r\n   \"id\": 1003,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Jed\",\r\n   \"city\": \"Montreal\",\r\n   \"country\": \"Canada\",\r\n   \"description\": \"Undefined description for Hotel Jed\"\r\n },\r\n {\r\n   \"id\": 1004,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Red\",\r\n   \"city\": \"Tokyo\",\r\n   \"country\": \"Japan\",\r\n   \"description\": \"Undefined description for Hotel Red\"\r\n },\r\n {\r\n   \"id\": 1005,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Ed\",\r\n   \"city\": \"Athens\",\r\n   \"country\": \"Greece\",\r\n   \"description\": \"Undefined description for Hotel Ed\"\r\n },\r\n {\r\n   \"id\": 1006,\r\n   \"type\": \"hotel\",\r\n   \"name\": \"Hotel Ged\",\r\n   \"city\": \"Ostende\",\r\n   \"country\": \"Belgium\",\r\n   \"description\": \"Undefined description for Hotel Ged\"\r\n }\r\n]";
    
    
//    [
//     {
//       "id": 1000,
//       "type": "hotel",
//       "name": "Hotel Ted",
//       "city": "Paris",
//       "country": "France",
//       "description": "Undefined description for Hotel Ted"
//     },
//     {
//       "id": 1001,
//       "type": "hotel",
//       "name": "Hotel Fred",
//       "city": "London",
//       "country": "England",
//       "description": "Undefined description for Hotel Fred"
//     },
//     {
//       "id": 1002,
//       "type": "hotel",
//       "name": "Hotel Ned",
//       "city": "Balmain",
//       "country": "Australia",
//       "description": "Undefined description for Hotel Ned"
//     },
//     {
//       "id": 1003,
//       "type": "hotel",
//       "name": "Hotel Jed",
//       "city": "Montreal",
//       "country": "Canada",
//       "description": "Undefined description for Hotel Jed"
//     },
//     {
//       "id": 1004,
//       "type": "hotel",
//       "name": "Hotel Red",
//       "city": "Tokyo",
//       "country": "Japan",
//       "description": "Undefined description for Hotel Red"
//     },
//     {
//       "id": 1005,
//       "type": "hotel",
//       "name": "Hotel Ed",
//       "city": "Athens",
//       "country": "Greece",
//       "description": "Undefined description for Hotel Ed"
//     },
//     {
//       "id": 1006,
//       "type": "hotel",
//       "name": "Hotel Ged",
//       "city": "Ostende",
//       "country": "Belgium",
//       "description": "Undefined description for Hotel Ged"
//     }
//    ]";
    
    
    
}


@end
