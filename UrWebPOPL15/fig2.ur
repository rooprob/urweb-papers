structure Room : sig
    type id
    val rooms : transaction (list {Id : id, Title : string})
    val chat : id -> transaction page

end = struct

    table room : {Id: int, Title: string}
    table message : {Room: int, When: time, Text: string}

    fun chat id =
        let
            fun say r =
                dml(INSERT INTO message (Room, When, Text) VALUES ({[id]}, CURRENT_TIMESTAMP, {[r.Text]}));
                chat id
        in
            title <- oneRowE1(SELECT (room.Title) FROM room WHERE room.Id = {[id]});
            log <- queryX1(SELECT message.Text
                            FROM message
                            WHERE message.Room = {[id]}
                            ORDER BY message.When)
                            (fn r => <xml>
                                {[r.Text]}
                                <br/>
                            </xml>);
            return <xml>
                <body>
                    <h1>Chat room: {[title]}</h1>
                    <form>
                        Add message: <textbox{#Text}/>
                        <submit value="Add" action={say}/>
                    </form>
                    <hr/>
                    {log}
                </body>
            </xml>
        end
    val rooms = queryL1(SELECT * FROM room ORDER BY room.Title)
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
