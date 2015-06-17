# encoding: utf-8

module MGT
  class AbstractPresenter

    def initialize(name = 'metrics')
      @name = name
    end

    def print(data)
      raise NoMethodError.new('Called abstract method :print')
    end

  end
end