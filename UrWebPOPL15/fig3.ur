structure Log : sig
    type t
    val create : transaction t
    val append : t -> string -> transaction {}
    val render : t -> xbody

end = struct

    datatype log =
      Nil
    | Cons of string * source log

    type t = {
        Head : source log,
        Tail : source (source log)
        }

    val create =
        s <- source Nil;
        s' <- source s;
        return {Head = s, Tail = s'}

    fun append t text =
        s <- source Nil;
        oldTail <- get t.Tail;
        set oldTail (Cons (text, s));
        set t.Tail s;

        log <- get t.Head;

        case log of
          Nil => set t.Head (Cons (text, s))
        | _ => return ()

    fun render' log =
        case log of
          Nil => <xml/>
        | Cons (text, rest) => <xml>
            {[text]}<br/>
            <dyn signal={log <- signal rest;
              return (render' log)}/>
          </xml>

    fun render t = <xml>
        <dyn signal={log <- signal t.Head;
          return (render' log)}/>
      </xml>
end
