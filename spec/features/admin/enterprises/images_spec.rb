require "spec_helper"

feature "Managing enterprise images" do
  include AuthenticationWorkflow
  include WebHelper

  context "as an Enterprise user", js: true do
    let(:enterprise_user) { create_enterprise_user(enterprise_limit: 1) }
    let(:distributor) { create(:distributor_enterprise, name: "First Distributor") }

    before do
      enterprise_user.enterprise_roles.build(enterprise: distributor).save!

      quick_login_as enterprise_user
      visit edit_admin_enterprise_path(distributor)
    end

    describe "images for an enterprise", js: true do
      def go_to_images
        within(".side_menu") do
          click_link "Images"
        end
      end

      before do
        go_to_images
      end

      scenario "editing logo" do
        # Adding image
        attach_file "enterprise[logo]", File.join(Rails.root, "app/assets/images/logo-white.png")
        click_button "Update"

        expect(page).to have_content("Enterprise \"#{distributor.name}\" has been successfully updated!")

        go_to_images
        within ".page-admin-enterprises-form__logo-field-group" do
          expect(page).to have_selector(".image-field-group__preview-image")
          expect(html).to include("logo-white.png")
        end

        # Replacing image
        attach_file "enterprise[logo]", File.join(Rails.root, "app/assets/images/logo-black.png")
        click_button "Update"

        expect(page).to have_content("Enterprise \"#{distributor.name}\" has been successfully updated!")

        go_to_images
        within ".page-admin-enterprises-form__logo-field-group" do
          expect(page).to have_selector(".image-field-group__preview-image")
          expect(html).to include("logo-black.png")
        end
      end

      scenario "editing promo image" do
        # Adding image
        attach_file "enterprise[promo_image]", File.join(Rails.root, "app/assets/images/logo-white.png")
        click_button "Update"

        expect(page).to have_content("Enterprise \"#{distributor.name}\" has been successfully updated!")

        go_to_images
        within ".page-admin-enterprises-form__promo-image-field-group" do
          expect(page).to have_selector(".image-field-group__preview-image")
          expect(html).to include("logo-white.jpg")
        end

        # Replacing image
        attach_file "enterprise[promo_image]", File.join(Rails.root, "app/assets/images/logo-black.png")
        click_button "Update"

        expect(page).to have_content("Enterprise \"#{distributor.name}\" has been successfully updated!")

        go_to_images
        within ".page-admin-enterprises-form__promo-image-field-group" do
          expect(page).to have_selector(".image-field-group__preview-image")
          expect(html).to include("logo-black.jpg")
        end
      end
    end
  end
end