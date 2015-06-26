package com.svn.client;

import java.util.ArrayList;
import java.util.List;
import java.text.ParseException;

import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.SVNURL;
import org.tmatesoft.svn.core.auth.ISVNAuthenticationManager;
import org.tmatesoft.svn.core.internal.io.dav.DAVRepositoryFactory;
import org.tmatesoft.svn.core.io.SVNRepository;
import org.tmatesoft.svn.core.io.SVNRepositoryFactory;
import org.tmatesoft.svn.core.wc.SVNWCUtil;



/*
 * Sandbox
 *  
 */
public class SvnWorks {
	
	@SuppressWarnings("null")
	public static void main (String[] args) throws SVNException, ParseException {
		 
        DAVRepositoryFactory.setup( );
 
//        String url = "https://subversion.devfactory.com/repos/ETI/branches/releases/LBP2014-09";
//        String name = "roman.kotsiy";
//        String password = "aCq3eRgA";
//        URL : https://svnnew.softserveinc.com/svnroot-ss/JSpirit_IWay/OmniPatient/trunk
//        username : infbuildiway
//        password : 2euIgl2dTEZzjy        
//        URL : https://fccsvn01.freeconferencecall.com/repo
//        username : smbuild@softserveinc.com
//        password : Cenachusac1        

        String url = "https://svnnew.softserveinc.com/svnroot-ss/JSpirit_IWay/OmniPatient/trunk";
        	
        String name = "infbuildiway";
        String password = "2euIgl2dTEZzjy";
        
        SVNRepository repository = null;
//      repository = SVNRepositoryFactory.createLocalRepository( new File("c:\\test\\traywindow-sciter-mac"), true, false);
//      repository = 
 //     SVNRepositoryFactory. create(SVNRepositoryFactory.createLocalRepository( new File("c:\\test\\traywindow-sciter-mac"), true, true));
        
        repository = SVNRepositoryFactory.create(SVNURL.parseURIEncoded( url ) );//c:\test\traywindow-sciter-mac\
        
        ISVNAuthenticationManager authManager = SVNWCUtil.createDefaultAuthenticationManager( name, password );
        repository.setAuthenticationManager( authManager );      
        			 
		SVNStatistics svn_stat = new SVNStatistics(authManager, repository);
		java.util.Date date = new java.util.Date();
		
		List<String> testList =   new ArrayList<String>();
		
		testList.add("*.css");
		testList.add("*.groovy");
		testList.add("*.less");

        System.out.println(" Start - " + date.toString());				

		svn_stat.setAcceptedExtension(testList);
				        
  	    System.out.println(svn_stat.getChangesForRevisions(16138, 16139, false));
  	    
		java.util.Date _date = new java.util.Date();
  	    
        System.out.println(" End - " + _date.toString());				
  	    
	}
	
}