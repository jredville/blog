steps_for(:webrat) do
  When "the user goes to $path" do |path|
    visits path
  end
  When "the user types '$text' into the $field field" do |text, field|
    fills_in field, :with => text 
  end
  When "the user clicks the '$button' button" do |button|
    clicks_button button
  end
  When "the user clicks the '$link' link" do |link|
    clicks_link link
  end
  When "the user logs in" do
    visits '/'
    fills_in 'login', :with => 'test_user'
    fills_in 'password', :with => 'password'
    clicks_button 'Log in'
  end
	
  Then "the title should be '$title'" do |title|
    response.should have_tag('title', title)
  end
  Then "the $item should include '$text'" do |item, text|
    response.should have_tag(item, /#{text}/)
  end
  Then "the page should contain the text '$text'" do |text|
    response.should have_text(/#{text}/)
  end
  Then "there should be a field named '$field'" do |field|
    response.should have_tag(field)
  end
  Then "there should be a submit button named '$name', with the label '$label'" do |name, label|
    response.should match_xpath("//input[@type='submit'][@name='#{name}'][@value='#{label}']")
  end
  
  When "the user fills in the signup form" do
    email, password = "foobar@sorensonmedia.com", "f00bar"
    fills_in "person[first_name]", :with => "Foo"
    fills_in "person[last_name]", :with => "Bar"
    selects "February"
    selects "11"
    selects "Male"
    fills_in "person[birth][year]", :with => "1977"
    fills_in "email_address[email]", :with => email
    fills_in "email_address[email_confirmation]", :with => email
    fills_in "account[username]", :with => "foobar"
    fills_in "account[password]", :with => password
    fills_in "account[password_confirmation]", :with => password
    checks "person[policy]"
  end    
end