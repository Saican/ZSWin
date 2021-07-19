/*
	ZSWin_EventDataPacket.zs
	
	Event System Utility Class

*/

/*
	This is a utility class used by the Event System
	allowing information to be processed by events other
	than NetworkProcess.

	Currently only WorldThingDied is supported, but any
	of the world events should be easily supported.

*/
class EventDataPacket
{
	/*
		Each packet can contain multiple pieces of
		information.  This is done through special
		command formatting.

	*/
	array<DataNode> Nodes;

	/*
		This enum represents what event the
		packet should be processed by.

		This is the key to making this generic.
		It doesn't tell the event how to process
		the info, just how to read it; ie, do
		whatever with the data in each packet,
		the packet just controls how that data
		is stored.
	
	*/
	enum EVENTTYP
	{
		EVTYP_WorldThingDied,
		EVTYP_Any,
	};
	EVENTTYP Event;

	/*
		The constructor arg list has a place for a DataNode,
		but it can be ignored if more than one node will
		be stored in the array.

        The event type will more than likely be the more useful arg.
	*/
	EventDataPacket Init(EVENTTYP Event = EVTYP_Any, DataNode Node = null)
	{
		if (Node)
			Nodes.Push(Node);
		self.Event = Event;
		return self;
	}
}

/*
	This is a helper class for the EventDataPacket
	that stores the data, regardless of type, as a
	string.

*/
class DataNode
{
	string Data;

	/*
		The DTYPE enum determines the type
		the data corresponds to, allowing
		for proper cast control.  Only castable
		types are supported.

		* Whatever I forgot that is castable can/will
		be added whenever I get to it/somebody complains. *
	
	*/
    clearscope static DTYPE stringToDataType(string e)
    {
        if (e ~== "int")
            return DTYPE_int;
        if (e ~== "float")
            return DTYPE_float;
        if (e ~== "bool")
            return DTYPE_bool;
        if (e ~== "string")
            return DTYPE_string;
        else
            return DTYPE_NULL;
    }

	enum DTYPE
	{
		DTYPE_int,
		DTYPE_float,
		DTYPE_bool,
		DTYPE_string,
        DTYPE_NULL,
	};
	DTYPE Type;

	DataNode Init(string Data, DTYPE Type = DTYPE_string)
	{
		self.Data = Data;
		self.Type = Type;
		return self;
	}
}