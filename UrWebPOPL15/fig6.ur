open Fig3

structure Room : sig
    type id
    val rooms : transaction (list {Id : id, Title : string})
    val chat : id -> transaction page

end = struct

    table room : {Id: int, Title: string}
    table message : {Room: int, When: time, Text: string}
    table subscriber : {Room: int, Chan: channel string}

    val rooms = queryL1(SELECT * FROM room ORDER BY room.Title)
    fun chat id =
        let
            fun say text  =
                dml(INSERT INTO message (Room, When, Text) VALUES ({[id]}, CURRENT_TIMESTAMP, {[text]}));
                queryI1(SELECT subscriber.Chan FROM subscriber
                        WHERE subscriber.Room = {[id]})
                        (fn r => send r.Chan text)
        in
            chan <- channel;
            dml(INSERT INTO subscriber (Room, Chan) VALUES ({[id]}, {[chan]}));
            title <- oneRowE1(SELECT (room.Title) FROM room WHERE room.Id = {[id]});
            initial <- queryL1(SELECT message.Text, message.When
                            FROM message
                            WHERE message.Room = {[id]}
                            ORDER BY message.When DESC);

            text <- source "";
            log <- Log.create ;
            return <xml>
                <body onload={
                    let
                      fun listener() =
                        text <- recv chan;
                        Log.append log text;
                        listener()
                      in
                        spawn (listener ());
                        List.app (fn r => Log.append log r.Text) initial
                      end }>
                    <h1>Chat room: {[title]}</h1>
                    Add message: <ctextbox source={text}/>
                    <button value="Add" onclick={fn _ =>
                      txt <- get text;
                      set text "";
                      rpc (say txt) }/>
                  <hr/>
                  {Log.render log}
                </body>
            </xml>
        end
end

fun main () =
    rooms <- Room.rooms;
    return <xml>
        <body>
            <h1>List of rooms</h1>
            {List.mapX(fn r =>
              <xml>
                  <li><a link={Room.chat r.Id}>{[r.Title]}</a></li>
              </xml>)
            rooms
            }
        </body>
    </xml>
