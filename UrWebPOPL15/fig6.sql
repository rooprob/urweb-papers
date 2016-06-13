CREATE TABLE uw_Fig6_Room_room(uw_id int8 NOT NULL, uw_title text NOT NULL
 );
 
 CREATE TABLE uw_Fig6_Room_message(uw_room int8 NOT NULL, 
                                    uw_when timestamp NOT NULL, 
                                    uw_text text NOT NULL
  );
  
  CREATE TABLE uw_Fig6_Room_subscriber(uw_room int8 NOT NULL, 
                                        uw_chan int8 NOT NULL
   );
   
   