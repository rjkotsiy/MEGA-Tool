package com.tfs.query;


public class TFSWorkItem {
	
	/**
	 * constructor
	 * 
	 * @param ID
	 * @param workItemName
	 * @param assignedTo
	 * @param state
	 * @param effort
	 * @param tags
	 * 
	 * @throws none 
	 */
	TFSWorkItem(
			int ID,
			String workItemName,
			String assignedTo,
			String state,
			String workItemType,
			String effort,
			String estimate,
			String tags
		)
	{
		_ID = ID;
		_workItemName = workItemName;
		_assignedTo = assignedTo;
		_state = state;
		_effort = effort;
		_tags = tags;
		_workItemType = workItemType;
		_estimate = estimate;		
	}
	
	
	/**
	 * copy constructor
	 * 
	 * @param aTFSWorkItem
	 * @throws none 
	 */
	TFSWorkItem (TFSWorkItem aTFSWorkItem)
	{
		this(
				aTFSWorkItem.getID(),
				aTFSWorkItem.getWorkItemName(),
				aTFSWorkItem.getAssignedTo(),
				aTFSWorkItem.getState(),
				aTFSWorkItem.getWorkItemType(),
				aTFSWorkItem.getEffort(),
				aTFSWorkItem.getEstimate(),
				aTFSWorkItem.getTags()
			);
	}
	
	public int getID() {return _ID;};
	public String getWorkItemName() {return _workItemName;};
	public String getAssignedTo() {return _assignedTo;};
	public String getState() {return _state;};
	public String getEffort() {return _effort;};
	public String getTags() {return _tags;};
	public String getEstimate() {return _estimate;};
	public String getWorkItemType() {return _workItemType;};
	
	private int _ID;
	private String _workItemName;
	private String _assignedTo;
	private String _state;
	private String _effort;
	private String _tags;
	private String _workItemType;
	private String _estimate;
	

}
