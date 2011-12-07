module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the homepage/
      '/'

    when /the messageboard "([^\"]+)"/i
      messageboard = @site.messageboards.find_by_name($1)
      messageboard_path(messageboard)

    when /the add a new thread page for "([^\"]+)"/i
      messageboard = @site.messageboards.find_by_name($1)
      new_messageboard_topic_path(messageboard)

    when /the topic listing page/i
      messageboard = @site.messageboards.first
      messageboard_topics_path(messageboard)

    when /edit the latest thread/i
      messageboard = Messageboard.first
      topic = messageboard.topics.latest.first
      edit_messageboard_topic_path(messageboard, topic)

    when /the most recently updated thread on "([^\"]+)"/i
      messageboard = @site.messageboards.find_by_name($1)
      topic = messageboard.topics.latest.first
      messageboard_topic_path(messageboard, topic)

    when /the sign up page/i
      new_user_registration_path( THREDDED[:default_site] )

    when /the sign in page/i
      new_user_session_path( THREDDED[:default_site] )

    when /the password reset request page/i
      new_user_password_path( THREDDED[:default_site] )

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
