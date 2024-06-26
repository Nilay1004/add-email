# frozen_string_literal: true

Rails.application.config.after_initialize do
  require_dependency 'user_email'
  
  class ::UserEmail
    after_save :copy_email_to_test_email

    private

    def copy_email_to_test_email
      if self.test_email != self.email
        self.update_column(:test_email, self.email)
      end
    end

    # Override methods that search by email with logging
    def self.find_by_email(email)
      Rails.logger.info "Searching UserEmail by test_email: #{email}"
      find_by(test_email: email)
    end

    def self.find_by_email!(email)
      Rails.logger.info "Searching UserEmail by test_email!: #{email}"
      find_by!(test_email: email)
    end

    def self.exists_with_email?(email)
      Rails.logger.info "Checking existence of UserEmail by test_email: #{email}"
      exists?(test_email: email)
    end
  end

  # Ensure other parts of the application use test_email for searches with logging
  module EmailOverride
    def find_user_by_email(email)
      Rails.logger.info "Searching User by test_email: #{email}"
      UserEmail.find_by(test_email: email)&.user
    end

    def find_user_by_email!(email)
      Rails.logger.info "Searching User by test_email!: #{email}"
      UserEmail.find_by!(test_email: email)&.user
    end
  end

  # Override methods in User model if necessary
  require_dependency 'user'
  class ::User
    singleton_class.prepend EmailOverride
  end
end