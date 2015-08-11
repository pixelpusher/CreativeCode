LinkedList<IUndoAction> undoActions;


void initializeUndoActions()
{
  undoActions = new LinkedList<IUndoAction>();    
}

interface IUndoAction
{
  void action();
}


void undo()
{
  
  try 
  {
    IUndoAction undoAction = undoActions.removeLast();
    undoAction.action();
  }
  catch (Exception e)
  {
    
  }
}

void addUndoAction( IUndoAction undoAction )
{
  undoActions.addLast(undoAction);
}
