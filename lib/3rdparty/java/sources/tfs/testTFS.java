package com.tfs.query;

import java.util.LinkedList;
import java.util.List;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.net.URISyntaxException;
import java.text.ParseException;

import javax.xml.ws.handler.Handler;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

public class testTFS {

	
    /** 
     * @param args 
     * @throws URISyntaxException 
     * @throws InterruptedException 
     * @throws ParseException 
     */ 
    public static void main(String[] args) throws URISyntaxException, InterruptedException, ParseException 
	{
        try {
    	
			QueryTFSData testClass = null;
			
			testClass =
//				new QueryTFSData("http://localhost:8080/tfs", "SOFTSERVE\\rkotsiy", "B3#asd12tamTam8");
			
   			new QueryTFSData("https://rkotsiy.visualstudio.com/DefaultCollection", "rkotsiy@softserveinc.com", "55Molaadebisi555");
												
			List<String> l = new LinkedList<String>();
			
			l.add("*.*");
			
			testClass.setAcceptedExtension(l);
			
			testClass.getRevisions("SEDataFetch", "17/06/2015", "26/06/2015");
			System.out.println(testClass.getChanges(13, 12));
						
			int it = 0;
			
			
//    	final TFS_ERROR_CODES err_code = testClass.fetchTFSMetrics("MetricsFetch", "01/01/2014", "03/02/2015", "Technical Debt");
//		//	err_code = testClass.fetchTFSMetrics("MetricsFetch", "01/01/2014", "03/02/2015", "Technical Debt");
//			
//			if (err_code == TFS_ERROR_CODES.TFS_SUCCESS)
//			{
//				String json_string = testClass.toJSON();
//				Double est = testClass.getDefectEstimatesWithoutTechDebt();
//				Double estT = testClass.getDefectEstimatesWithTechDebt();
//				int bs = testClass.getBacklogSizeWithTechDebt();
//				System.out.println("Success");	
//			}
//			else if (err_code == TFS_ERROR_CODES.TFS_EXCEPTION_ACCESS_DENIED)
//			{
//				System.out.println("Access denied");
//			}
//			else if (err_code == TFS_ERROR_CODES.TFS_EXCEPTION_INVALID_QUERY)
//			{
//				System.out.println("Invalid query");    		
//			}
//			else if (err_code == TFS_ERROR_CODES.TFS_EXCEPTION_CONNECTION_ERROR)
//			{
//				System.out.println("Connection error");    		
//			}
			
        } catch (Exception e) {
		// TODO Auto-generated catch block
		e.printStackTrace();}
	}
}
