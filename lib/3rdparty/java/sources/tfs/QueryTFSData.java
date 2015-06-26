package com.tfs.query;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.net.URISyntaxException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.io.FilenameUtils;
import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.apache.log4j.RollingFileAppender;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import com.microsoft.tfs.core.TFSTeamProjectCollection;
import com.microsoft.tfs.core.clients.versioncontrol.VersionControlClient;
import com.microsoft.tfs.core.clients.versioncontrol.exceptions.ServerPathFormatException;
import com.microsoft.tfs.core.clients.versioncontrol.soapextensions.Change;
import com.microsoft.tfs.core.clients.versioncontrol.soapextensions.ChangeType;
import com.microsoft.tfs.core.clients.versioncontrol.soapextensions.Changeset;
import com.microsoft.tfs.core.clients.versioncontrol.soapextensions.Item;
import com.microsoft.tfs.core.clients.versioncontrol.soapextensions.RecursionType;
import com.microsoft.tfs.core.clients.versioncontrol.specs.version.DateVersionSpec;
import com.microsoft.tfs.core.clients.versioncontrol.specs.version.LatestVersionSpec;
import com.microsoft.tfs.core.clients.workitem.WorkItem;
import com.microsoft.tfs.core.clients.workitem.WorkItemClient;
import com.microsoft.tfs.core.clients.workitem.fields.Field;
import com.microsoft.tfs.core.clients.workitem.fields.FieldCollection;
import com.microsoft.tfs.core.clients.workitem.project.Project;
import com.microsoft.tfs.core.clients.workitem.query.WorkItemCollection;
import com.microsoft.tfs.core.clients.workitem.query.WorkItemLinkInfo;
import com.microsoft.tfs.core.exceptions.TFSUnauthorizedException;
import com.microsoft.tfs.core.httpclient.Credentials;
import com.microsoft.tfs.core.httpclient.UsernamePasswordCredentials;

import difflib.DiffUtils;
import difflib.Patch;



public class QueryTFSData {
	
	// @public methods ->
	
	/** 
     * constructor
     * 
     * @param serverUrl, 
     *        domainUser,
     *        password
	 * @throws URISyntaxException 
	 * @throws FileNotFoundException 
     * @throws none
     */ 
	
    public QueryTFSData(
    		String serverUrl,
    		String domainUser,
    		String password
    	) throws URISyntaxException, FileNotFoundException
    {
    	
    	System.setProperty(
    			"com.microsoft.tfs.jni.native.base-directory",
    			// NOTE, rkotsiy: path was hardcoded for testing purpose  
    			// "D:\\MGT\\WIP\\lib\\3rdparty\\java\\sdk\\TFS-SDK-11.0.0\\redist\\native"
    			"lib/3rdparty/java/sdk/TFS-SDK-11.0.0/redist/native"
    		);

        _teamCollection = _tfsConnect(serverUrl, domainUser, password);
        
        _versionControlClient = _teamCollection.getVersionControlClient();
    	    	
    	_workitems = new ArrayList<TFSWorkItem>();

    	_defect_estimates_whithout_techdebt = 0.0;
    	_defect_estimates_whith_techdebt = 0.0;
    	_backlog_size_with_techdebt = 0;    
    	
    	
    }
    
	/*
	 * set accepted file extensions  
	 * 
	 * throws
	 * none
	 *  
	 */
	public void setAcceptedExtension(List<String> acceptedExtension ) {
		_acceptedExtension = acceptedExtension;		
	}
            
    public int getChanges (int changeSetId1, int changeSetId2) {
    	    	
    	Changeset changeSet =  _versionControlClient.getChangeset(changeSetId1);
    	    	
    	int totalDiffCount = 0;
    	
		for(Change change : changeSet.getChanges()) {
			
	        Item item = change.getItem();
	        ChangeType type = change.getChangeType();
	        	        
	        if (!item.getItemType().toUIString().equalsIgnoreCase("File")) continue;
	        
	        if (!checkExtension( item.getServerItem()) ) continue;
	        	        	        				        
	        if (type.contains(ChangeType.DELETE) || type.contains(ChangeType.ADD)) { // detect ..ther the file was added or removed
				List<String> fileLines = getTempFileToStringList(item);					
        		
				totalDiffCount += fileLines.size();	        	
	        }	
	        	                			                			        	        
	        if ( type.contains(ChangeType.EDIT) && item.getItemType().toUIString().equalsIgnoreCase("File")) {	        	
	        	totalDiffCount +=  compareToChangeSet(changeSetId2, item);
	        }	        	        
		}
					    	
    	return totalDiffCount;    
    }

    
	private List<String> getTempFileToStringList(Item item) {
		
		File file = item.downloadFileToTempLocation(_versionControlClient, item.getServerItem());		

		List<String> lines = fileToLines(file.getPath());
		
		file.delete();
		
    	return lines;						
	}
    
    
    public int compareToChangeSet(int changeSetId, Item changeSetItem) {
    	
    	Changeset changeSet =  _versionControlClient.getChangeset(changeSetId);
    	
		for(Change change : changeSet.getChanges()) {
			
	        Item item = change.getItem();
	                			                			        	        
	        if ( item.getServerItem().equalsIgnoreCase(changeSetItem.getServerItem())) {     		        
				
				if ( !item.getContentHashValue().toString().equals(changeSetItem.getContentHashValue().toString()) ) {					
										
					List<String> original = getTempFileToStringList(item);					
					List<String> revised = getTempFileToStringList(changeSetItem);					
			    				    				    				        			    				    	
			    	Patch patch = DiffUtils.diff(original, revised);
			    	
			    	List<String> unidiff = DiffUtils.generateUnifiedDiff("Before", "After", original, patch, 0);
			    	
			    	int diffCount = 0;
			    	
			    	for (String string : unidiff) {
			    		
		               	if ( (string.startsWith("+++ ") || string.startsWith("--- ")) ) continue;
	    	        	
	                	if (string.charAt(0) == '-' || string.charAt(0) == '+') {
	                		diffCount++;
	                	}	 			    		
			    	}
			    				    						
					return diffCount;			    				    											
				}														
	        }
		}
    	    	
    	return 0;  // = 0
    }
    
    
    public List<Changeset> getRevisions (String projectName, String startDate, String endDate) throws ServerPathFormatException, ParseException {
    	        
    	Changeset[] changeSet;
    
		changeSet = _versionControlClient.queryHistory(
				"$/" + projectName,
				LatestVersionSpec.INSTANCE,
				0,
				RecursionType.FULL,
				null,
				new DateVersionSpec(startDate),
				new DateVersionSpec(endDate),
				Integer.MAX_VALUE,
				false,
				true,
				true,
				true
			);
		
		List<Changeset> revisionList= new LinkedList<Changeset>();
		
		for (Changeset changeItem : changeSet) {
			
			revisionList.add(changeItem);
		}
		
       return revisionList;     	
    }
    
    
    /**
     * run query and get workitems list 
     * @param projectName,
     *        iterationPath,
     *        workItemStateConditions
     * @throws URISyntaxException 
     * @throws InterruptedException 
     * @throws ParseException 
     */ 
	public TFS_ERROR_CODES fetchTFSMetrics (String projectName, String createdDate, String closedDate, String tags)
			throws URISyntaxException, InterruptedException, ParseException 
    {
        	        
        Project project;
        
        try
        {
        	project = _teamCollection.getWorkItemClient().getProjects().get(projectName);
        }
        catch (Exception exception)
        {
        	if (exception instanceof TFSUnauthorizedException)
        	{
        		return TFS_ERROR_CODES.TFS_EXCEPTION_ACCESS_DENIED;
        	}
        	        	
        	return TFS_ERROR_CODES.TFS_EXCEPTION_CONNECTION_ERROR;
        }
        
        WorkItemClient workItemClient = new WorkItemClient(_teamCollection, null, null, null); 
        workItemClient = project.getWorkItemClient();
                        
        // Define the WIQL query.          
        String wiqlQuery = 
        		"Select ID, Title, Effort, Tags, State, [System.AssignedTo], [Created Date], [Closed Date],  [Remaining Work], [Work Item Type] from WorkItems where (State <> 'Done' and State <> 'Removed' ) and ([Work Item Type] = 'Bug' or [Work Item Type] = 'Task') " +
                 " and [Created Date] <= '" + closedDate + "'"; 
  
        WorkItemCollection workItems = null;
        
        // Run the query and get the results.    
        try
        {
        	workItems = workItemClient.query(wiqlQuery);
        }
        catch (Exception exception)
        {
    		return TFS_ERROR_CODES.TFS_EXCEPTION_INVALID_QUERY;        	
        }
                    
        for (int i = 0; i < workItems.size(); i++)          
        { 

            final WorkItem workItem = workItems.getWorkItem(i);
            final FieldCollection fieldCollection =  workItem.getFields();
            
            final int _id = workItem.getID();
            final String _title = workItem.getTitle();
                                 	   
        	final String _tags = _getField_S(fieldCollection, "Tags"); 
         	final String _state = _getField_S(fieldCollection, "State");         	
        	final String _assignedto = _getField_S(fieldCollection, "System.AssignedTo");        	        	
        	final String _workitemtype = _getField_S(fieldCollection, "Work Item Type");
        	Double _effort = _getField_D(fieldCollection, "Effort");
        	Double _remainingwork = _getField_D(fieldCollection, "Remaining Work");
        	
        	Double _final_estimate = 0.0;
        	
        	if  (_workitemtype.equalsIgnoreCase("Bug"))
        	{
        		_final_estimate = _effort;
        	}
        	else if (_workitemtype.equalsIgnoreCase("Task"))
        	{
        		_final_estimate = _remainingwork;        		
        	}
        	        	            
//        	if (_workitemtype.equalsIgnoreCase("Bug") && !_hasChilds(workItemClient, _id) )
//        	{
//       			_remainingwork = _effort;
//       			_effort = 0.0;
//        	}

            if (_tags.contains(tags) && !tags.trim().isEmpty() )
         	{
	            	_backlog_size_with_techdebt++;
         	}
        	                                    
         	Field field = fieldCollection.getField("System.CreatedDate");   
            Date _created_date = (Date) field.getValue();

            boolean _in_range = false;
            
            {
            	SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");            	
             
            	try {
             
            		Date date = formatter.parse(createdDate);
    				if ( _created_date.compareTo(date) > 0 || _created_date.compareTo(date) == 0)  	            
   	            	{
   	            		_in_range = true;	
   	            	}
             
            	} catch (ParseException e) {
            		e.printStackTrace();
            	}            	
            	
            }
            
            if (_in_range)
            {
	         	if (_tags.contains(tags) && !tags.trim().isEmpty())
	         	{
         			_defect_estimates_whith_techdebt  += _final_estimate;
	         	}
	         	else
	         	{
         			_defect_estimates_whithout_techdebt += _final_estimate;
	         	}         	
	         	
	         	final TFSWorkItem _tfsworkitem = 
	         			new TFSWorkItem(_id, _title, _assignedto, _state, _workitemtype, Double.toString(_effort), Double.toString(_final_estimate), _tags);
	        	
	        	_workitems.add(_tfsworkitem);
            }
        }         	
	                        
        return TFS_ERROR_CODES.TFS_SUCCESS;

    }


    /**
     * return defect total estimates without Technical Debt tag set  
     * @param none
     * @throws none 
     */ 
    public Double getDefectEstimatesWithoutTechDebt()
    {
    	return _defect_estimates_whithout_techdebt;
    }
    

    /**
     * return defect total estimates with Technical Debt tag set  
     * @param none
     * @throws none 
     */ 
    public Double getDefectEstimatesWithTechDebt()
    {
    	return _defect_estimates_whith_techdebt;
    }
    

    /**
     * return backlog size with Technical Debt tag set  
     * @param none
     * @throws none 
     */ 
    public int getBacklogSizeWithTechDebt()
    {
    	return _backlog_size_with_techdebt;
    }

    
    /**
     * return work items list
     * @param none
     * @throws none 
     */ 
    public ArrayList<TFSWorkItem> getWorkItems()
    {
    	return _workitems;
    }
    
  
    /**
     * return work items list in JSON format
     * @param none
     * @throws none 
     */ 
    @SuppressWarnings("unchecked")
	public String toJSON()
    {	
    	JSONObject _mainObj = null;
    	JSONArray _json_workitems_mid = new JSONArray();
    	
    	for (int i = 0 ; i < _workitems.size(); i++)
    	{
    		final TFSWorkItem _tfsworkitem = _workitems.get(i);
    		
	    	JSONObject _json_workitems = new JSONObject();
	    	_json_workitems.put("id", _tfsworkitem.getID());
	    	_json_workitems.put("title", _tfsworkitem.getWorkItemName());
	    	_json_workitems.put("type", _tfsworkitem.getWorkItemType());
	    	_json_workitems.put("assigned_to", _tfsworkitem.getAssignedTo());
	    	_json_workitems.put("state", _tfsworkitem.getState());
	    	_json_workitems.put("estimate", _tfsworkitem.getEstimate());
	    	_json_workitems.put("effort", _tfsworkitem.getEffort());
	    	_json_workitems.put("tags", _tfsworkitem.getTags());
	    	
	    	_json_workitems_mid.add(_json_workitems);
    	
	    	_mainObj = new JSONObject();
    	
	    	_mainObj.put("workitems", _json_workitems_mid);
    	}
    	
    	return _mainObj.toString();
    	
    }
    
	// @public methods -<


	// @private methods ->
    	
	private boolean checkExtension(String filename) {
		
		for (String extension :_acceptedExtension) {
			if ( extension.contains("*.*") )
				return true;
		}
		
        String ext = "*." + FilenameUtils.getExtension(filename);
                
		for (String extension :_acceptedExtension) {
			if ( extension.contains(ext) )
				return true;
		}
		
		return false;
	}
    

    // Helper method for get the file content
    private  List<String> fileToLines(String filename) {
    	
		List<String> lines = new LinkedList<String>();
	    
	    String line = "";
	    try {
	            BufferedReader in = new BufferedReader(new FileReader(filename));
	            while ((line = in.readLine()) != null) {
	                    lines.add(line);
	            }
	    } catch (IOException e) {
	            e.printStackTrace();
	    }
	    
	    return lines;
    }
    
    /**
     * method return true if work item have child linked objects
     * @param workitemClient
     * @param _id
     *        
     * @throws none 
     */ 
	@SuppressWarnings("unused")
	private static boolean _hasChilds(WorkItemClient workItemClient, int _id)
	{
		WorkItemLinkInfo[] linksInfo =
				workItemClient.createQuery("select [System.Id] from workitemlinks where [Source].[System.Id] = " + _id).runLinkQuery();
		
		return linksInfo.length != 0;
	}

    /**
     * method return the TFS work item field value
     * @param fieldCollection
     *        fieldName
     * @throws none 
     */ 
	private static String _getField_S (FieldCollection fieldCollection, String fieldName)
	{
      	Field field = fieldCollection.getField(fieldName);
      	
    	String value;
    	value = (String) field.getValue();
        return value = ( value == null) ? " " :  value;            
	}
    /**
     * method return the TFS work item field value
     * @param fieldCollection
     *        fieldName
     * @throws none 
     */ 
	private static Double _getField_D (FieldCollection fieldCollection, String fieldName)
	{
      	Field field = fieldCollection.getField(fieldName);
      	
        field= fieldCollection.getField(fieldName); 
        Double value = 0.0; 
        value = (Double) field.getValue();            
        return value = ( value == null) ? 0.0 :  value;            
	}
        
    /**
     * method return the object of team project collection in case of success connection
     * @param serverUrl,
     *        domainUser,
     *        password
     * @throws URISyntaxException 
     */ 
	private static TFSTeamProjectCollection _tfsConnect(String serverUrl, String domainUser, String password) throws URISyntaxException	
    {
    	TFSTeamProjectCollection teamCollecction = null;
    	
        try 
        {                	
        	java.net.URI serverURI = new java.net.URI (serverUrl);
        	
        	Credentials credentials =
        			new UsernamePasswordCredentials(domainUser, password);
        			        	
            teamCollecction =
            		new TFSTeamProjectCollection (serverURI, credentials);  
        }
        catch(Exception exception)
        {
        	return null;
        }
        
        return teamCollecction;
    	
    }
    
	private static List<String> _acceptedExtension;
	private VersionControlClient _versionControlClient;	
	private TFSTeamProjectCollection _teamCollection;
    private ArrayList<TFSWorkItem> _workitems;
    
	private double _defect_estimates_whithout_techdebt;
	private double _defect_estimates_whith_techdebt;
	private int _backlog_size_with_techdebt;

	 // @private <-
	
}

