class ZABST
{
	ZABST_Node Root;
	
	ZABST Init() { Root = null; return self; }
	
	/*
		Just borrowed Java's hash algorithm
	*/
	static int GetNameHash(string objectName)
	{
		int objectHash = 0;
		for (int i = 0; i < objectName.Length(); i++)
			objectHash = 31 * objectHash + objectName.ByteAt(i);
		return objectHash;
	}
	
	int Count() { return _count(root); }
	
	private int _count(ZABST_Node Tree)
	{
		int crtn = 0;
		if (Tree != null)
		{
			crtn++;
			crtn += _count(Tree.Left);
			crtn += _count(Tree.Right);
		}
		return crtn;
	}
	
	/*
		Public Insert Method
		Args: 	Data, reference to the Object-inheriting class
				objectName, this is a unique identifier for the node.
	
	*/
	void Insert(Object Data, string objectName)
	{
		if (Root == null)
			Root = new("ZABST_Node").Init(Data, objectName);
		else
			_insertBalance(_insert(Root, new("ZABST_Node").Init(Data, objectName)));
	}
	
	private ZABST_Node _insert(ZABST_Node bparent, ZABST_Node znode)
	{
		if (znode.Hash < bparent.Hash)
		{
			if (bparent.Left != null)
				return _insert(bparent.Left, znode);
			else
			{
				bparent.Left = znode;
				znode.Parent = bparent;
				bparent.setBalance();
				return bparent;
			}
		}
		else
		{
			if (bparent.Right != null)
				return _insert(bparent.Right, znode);
			else
			{
				bparent.Right = znode;
				znode.Parent = bparent;
				bparent.setBalance();
				return bparent;
			}
		}
	}
	
	private void _insertBalance(ZABST_Node parent)
	{
		if (parent.Parent != null)
		{
			if (parent.Parent.Left == parent && parent.Parent.Balance + 1 > 1)
			{
				if (parent.Balance > 0)
					_rotateLeftLeft(parent);
				else if (parent.Balance < 0)
					_rotateLeftRight(parent);
			}
			else if (parent.Parent.Right == parent && parent.Parent.Balance -1 < -1)
			{
				if (parent.Balance > 0)
					_rotateRightLeft(parent);
				else if (parent.Balance < 0)
					_rotateRightRight(parent);
			}
		}
	}
	
	private void _rotateParentSet(ZABST_Node parent, ZABST_Node beRotated)
	{
			if (parent.Parent.Left == parent)
				parent.Parent.Left = beRotated;
			else
				parent.Parent.Right = beRotated;
	}
	
	private void _rotateLeftLeft(ZABST_Node beRotated)
	{
		ZABST_Node bparent = beRotated.Parent;

		if (bparent.Parent == null)
		{
			root = beRotated;
			beRotated.Parent = null;
		}
		else
		{
			beRotated.Parent = bparent.Parent;
			_rotateParentSet(bparent, beRotated);
		}
		bparent.Parent = beRotated;
		if (beRotated.Right != null)
			bparent.Left = beRotated.Right;
		else
			bparent.Left = null;
		bparent.setBalance();
		beRotated.Right = bparent;
		beRotated.setBalance();
	}

	private void _rotateRightRight(ZABST_Node beRotated)
	{
		ZABST_Node bparent = beRotated.Parent;

		if (bparent.Parent == null)
		{
			root = beRotated;
			beRotated.Parent = null;
		}
		else
		{
			beRotated.Parent = bparent.Parent;
			_rotateParentSet(bparent, beRotated);
		}
		bparent.Parent = beRotated;
		if (beRotated.Left != null)
			bparent.Right = beRotated.Left;
		else
			bparent.Right = null;
		bparent.setBalance();
		beRotated.Left = bparent;
		beRotated.setBalance();
	}

	private void _rotateLeftRight(ZABST_Node bparent)
	{
		ZABST_Node beRotated = bparent.Right;
		beRotated.Parent = bparent.Parent;
		bparent.Parent = beRotated;
		if (beRotated.Left != null)
			bparent.Right = beRotated.Left;
		else
			bparent.Right = null;
		beRotated.Left = bparent;
		bparent.setBalance();

		_rotateLeftLeft(beRotated);
	}

	private void _rotateRightLeft(ZABST_Node bparent)
	{
		ZABST_Node beRotated = bparent.Left;
		beRotated.Parent = bparent.Parent;
		bparent.Parent = beRotated;
		if (beRotated.Right != null)
			bparent.Left = beRotated.Right;
		else
			bparent.Left = null;
		beRotated.Right = bparent;
		bparent.setBalance();

		_rotateRightRight(beRotated);
	}

	/*
		Public Find Method
		Args: 	objectName, unique name of the node
		Return:	ZABST_Node with the same name otherwise null
	
	*/	
	ZABST_Node Find(string objectName)
	{
		return _find(GetNameHash(objectName), root);
	}
	
	private ZABST_Node _find(int DataHash, ZABST_Node node)
	{
		if (node == null)
			return null;
		else if (DataHash == node.Hash)
			return node;
		else if (DataHash < node.Hash)
			return _find(DataHash, node.Left);
		else if (DataHash > node.Hash)
			return _find(DataHash, node.Right);
		else
			return null;
	}
	
	/*
		Public Delete Method
		Args:	objectName, unique name of the node
		
		NOTE! DOES NOT CURRENTLY HEIGHT BALANCE
		
	*/
	void Delete(string objectName)
	{
		_delete(GetNameHash(objectName), root);
	}
	
	private void _delete(int dataHash, ZABST_Node node)
	{
		// Find the node
		if (dataHash < node.Hash) // look to the left
			_delete(dataHash, node.Left);
		else if (dataHash > node.Hash) // look to the right
			_delete(dataHash, node.Right);
		else // got it
		{
			// single child checks - node is just eliminated
			if (node.Left == null)
				node = node.Right;
			else if (node.Right == null)
				node = node.Left;
			// both children are occupied
			else
			{
				ZABST_Node newParent = getPredecessor(node.Left.Hash, node.Left);
				if (newParent)
				{
					node.ObjectName = newParent.ObjectName;
					node.Hash = newParent.Hash;
					node.Data = newParent.Data;
					_delete(node.Left.Hash, node.Left);
				}
			}
		}
	}
	
	private ZABST_Node getPredecessor(int dataHash, ZABST_Node node)
	{
		while (node.Right != null)
			node = node.Right;
		return node;
	}
	
	int GetRootBalance() { return getBalance(Root); }
	
	int GetBalance(ZABST_Node node)
	{
		int bl = 0, 
			br = 0;
			
		if (node.Left != null)
		{
			bl++;
			bl += getBalance(node.Left);
		}
		
		if (node.Right != null)
		{
			br++;
			br += getBalance(node.Right);
		}
			
		return bl - br;
	}
}

class ZABST_Node
{
	string ObjectName;
	int Hash, Balance;
	ZABST_Node Parent, Left, Right;
	
	Object Data;
	
	void setBalance()
	{
		if (Left != null)
			Balance += 1;
		if (Right != null)
			Balance -= 1;
	}
	
	ZABST_Node Init(Object Data, string ObjectName)
	{
		self.ObjectName = ObjectName;
		self.Data = Data;
		Hash = ZABST.GetNameHash(ObjectName);
		Balance = 0;
		Parent = Left = Right = null;
		return self;
	}
}