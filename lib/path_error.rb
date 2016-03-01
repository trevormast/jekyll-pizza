class PathError < StandardError
  def initialize(msg = "Please choose a new path name. \
                      Paths may contain lowercase letters (a-z), \
                      numbers (0-9), dashes (-), and underscores (_).")
    super
  end
end
