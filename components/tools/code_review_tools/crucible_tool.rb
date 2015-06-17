# encoding: utf-8

require 'tools/code_review_tools/code_review_tool'
require 'tools/base_rest'

module MGT
  class CrucibleTool
    include BaseREST
    include MGT::CodeReviewTool

    def initialize args
      super(args)
      @url = URI(args.URL)
      @tool_name = 'Crucible'
    end

    ##
    # method check connection with incoming parameters
    def test_connection      
      str = escape_cru_project
      try(str)
    end

    ##
    # method return array of closed revisions, their hashes/numbers
    def array_of_revisions
      all_closed_reviews_for_range.map{|id| all_revisions_in_review(id)}.flatten.uniq
    end

    private

    ##
    # method return all revisions with status "Closed"
    def all_closed_reviews
      str = escape_cru_project + '&states=Closed'
      answer = send_GET_request(str)
      parse_response(answer.body)['detailedReviewData']
    end

    ##
    # method return all reviews with status "Closed" before "CloseDate" , their id number
    def all_closed_reviews_for_range
      array = all_closed_reviews.map do |review|
        review_closed_date = Date.parse(review['closeDate'])
        if review_closed_date <= Date.parse(@sprint_end_date) && review_closed_date >= Date.parse(@sprint_start_date)
          review['permaId']['id']
        end
      end
      array.compact
    end

    ##
    # method return all revision, were was added to review request
    def all_revisions_in_review review_id
      resp = send_GET_request("/rest-service/reviews-v1/#{review_id}/details")
      resp_body = parse_response(resp.body)['reviewItems']['reviewItem']
      revisions = resp_body.map{|item| item['toRevision']}
      revisions.uniq
    end

    ##
    # method escape Crucible
    def escape_cru_project
      URI.escape("/rest-service/reviews-v1/filter/details?project=#{@project}")
    end

  end
end