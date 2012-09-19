module ViewHelpers
  def moretext(number=1)
    return JSON(open("http://more.handlino.com/sentences.json?n=#{number}").read)["sentences"].join()
  end
end
