# frozen_string_literal: true

after_initialize do
  require_dependency 'user_email'
  
  class ::UserEmail
    after_save :copy_email_to_test_email

    private

    def copy_email_to_test_email
      if self.test_email != self.email
        self.update_column(:test_email, self.email)
      end
    end
  end
end