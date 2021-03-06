require "rails_helper"

feature "A visitor can sign up" do
  background do
    visit root_path
    within("nav") { click_link "Sign up" }
  end

  scenario "User signs up successfully" do
    fill_in("Email", with: "email@example.com")
    fill_in("Given name", with: "John")
    fill_in("user_password", with: "password", exact: true)
    fill_in("Password confirmation", with: "password")

    submit_form

    expect(page).to have_flash :success, "A message with a confirmation link has been sent to your email address. Please open the link to activate your account."
    expect(page).to_not have_content "User was successfully created"
    expect(current_path).to eq(root_path)

    # Signing up should create the user as a member
    expect(User.first).to be_member
  end

  scenario "User doesn't fill in details" do
    submit_form
    within("form") do
      # Errors show below the inputs, Capybara will show the error as follows
      expect(page).to have_content("can't be blank")
      expect(page).to have_css(".form-group.string.required.user_given_names.has-error")
      expect(page).to have_css(".form-group.password.required.user_password.has-error")
      expect(page).to have_content("Minimum is #{Rails.configuration.devise.password_length.min} characters")
    end
  end
end
