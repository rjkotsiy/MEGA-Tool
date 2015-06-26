package com.svn.client;

import java.io.ByteArrayOutputStream;
import java.text.ParseException;
import java.util.Arrays;
import java.util.List;

import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.SVNURL;
import org.tmatesoft.svn.core.auth.ISVNAuthenticationManager;
import org.tmatesoft.svn.core.internal.wc2.ng.SvnDiffGenerator;
import org.tmatesoft.svn.core.io.SVNRepository;
import org.tmatesoft.svn.core.wc.SVNDiffOptions;
import org.tmatesoft.svn.core.wc.SVNRevision;
import org.tmatesoft.svn.core.wc2.SvnDiff;
import org.tmatesoft.svn.core.wc2.SvnOperationFactory;
import org.tmatesoft.svn.core.wc2.SvnTarget;

/*
 * SVNStatistics class implementation
 * 
 * Implements fetching SVN statistics, count of changed code lines 
 * 
 */

public class SVNStatistics {

	/*
	 * Default constructor  
	 */
	public  SVNStatistics( ISVNAuthenticationManager authManager, SVNRepository repository ) {
		_authManager = authManager;		
		_repository = repository;
		
		_url = _repository.getLocation();

		final SvnOperationFactory svnOperationFactory = new SvnOperationFactory();

		svnOperationFactory.setAuthenticationManager(_authManager);
		
		final SvnDiffGenerator diffGenerator = new SvnDiffGenerator();
		
		diffGenerator.setForcedBinaryDiff(false);

		_diff = svnOperationFactory.createDiff();

		_diff.setDiffGenerator(diffGenerator);
		
		_diff.setDiffOptions(new SVNDiffOptions(true, true, true));
		
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

	/*
	 * return count of changed code lines in selected start end revisions 
	 * 
	 * throws
	 * ParseException, SVNException
	 *  
	 */
	public int getChangesForRevisions(long fromRev, long toRev) throws SVNException {

		int diff_count = 0;
						
		diff_count = getChanges(fromRev, toRev);						

		return diff_count;
	}

	
	private static int getChanges(long fromRev, long toRev) throws SVNException {
		
		ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
		
		_diff.setSource(SvnTarget.fromURL(_url), SVNRevision.create(fromRev),
				SVNRevision.create(toRev));
		
		_diff.setOutput(byteArrayOutputStream);				
	
		_diff.run();
				       						
		int total_diff_count = 0;
		int inside_block_diff_count = 0;
		
		String diff_string = byteArrayOutputStream.toString();
				
		final String fixed_diff_string = diff_string.replaceAll("No newline at end of file", line_separator);
		
        final List<String> diff_list =  Arrays.asList(fixed_diff_string.split(line_separator));
        										        
        for (int next_line = 0; next_line <= diff_list.size() - 1; next_line++ ) {
        	
        	final String current_diff_line = diff_list.get(next_line);
        	
        	if (current_diff_line.length() == 0) continue;
        	
        	// determine diff start block
        	if (current_diff_line.startsWith("Index: ")) {
        		
        		final String fileExtension = current_diff_line.substring(current_diff_line.lastIndexOf('.'));
        		
        		for (int inside_hunk_index = next_line; inside_hunk_index <=  diff_list.size() - 1; inside_hunk_index++) {
        			
        			next_line = inside_hunk_index;
        			
                	final String inside_diff_line = diff_list.get(inside_hunk_index);
                	
                	if (inside_hunk_index + 1 < diff_list.size() - 1)
                	{
                    	final String end_block_line = diff_list.get(inside_hunk_index + 1);
                    	
                    	// determine end block index
                    	if (end_block_line.startsWith("Index: ")) {
                    		
                    		if (checkExtentension(fileExtension)) {
                    			total_diff_count += inside_block_diff_count;
                    			break;
                    		}
                    	}
                	}
        			        			
                	if ( (inside_diff_line.startsWith("+++ ") || inside_diff_line.startsWith("--- ")) ) continue;
    	        	
                	if (inside_diff_line.charAt(0) == '-' || inside_diff_line.charAt(0) == '+') {
                		inside_block_diff_count++;
                	}	    	        	        			
        		}
        		
        		if (checkExtentension(fileExtension)) {        			
        			total_diff_count += inside_block_diff_count;
        		}    		
        	}        	    		 
        }
		
		return total_diff_count;
	
	}
	
	private static boolean allowAllExtension() {
		for (String extension :_acceptedExtension) {
			if ( extension.contains( "*.*") )
					return true;
		}
		return false;				
	}
	
	private static boolean checkExtentension(String fileExtension) {
		
		if ( allowAllExtension() )
			return true;
				
		int dot_index = fileExtension.indexOf('.');
		
		String hot1 = fileExtension.substring(dot_index, fileExtension.length());
					
		int return_index = hot1.indexOf('\t');
		
		if (dot_index == -1 || return_index == -1)
			return false;
		
		String normalExt = fileExtension.substring(dot_index, return_index);
		
		normalExt = "*" + normalExt; 
		
		for (String extension :_acceptedExtension) {
			if ( extension.contains( normalExt.trim() ) )
					return true;
		}
		return false;		
	}
	
	
	
			
	private static List<String> _acceptedExtension;
	private static SVNURL _url;	
	private static SvnDiff _diff;
	private static String line_separator = System.getProperty("line.separator");
	private  ISVNAuthenticationManager _authManager;
	private  SVNRepository _repository;

}
