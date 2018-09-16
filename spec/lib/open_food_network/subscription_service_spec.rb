require "spec_helper"
require "open_food_network/subscription_service"

module OpenFoodNetwork
  describe SubscriptionService do
    describe "availability of variants" do
      let!(:shop) { create(:enterprise) }
      let!(:supplier) { create(:supplier_enterprise) }
      let!(:product) { create(:product, supplier: supplier) }
      let!(:variant) { product.variants.first }

      let(:service) { described_class.new(shop) }

      context "if the shop is the supplier for the product" do
        let!(:supplier) { shop }

        it "is available" do
          expect(service.available_variants).to include(variant)
        end
      end

      context "if the supplier is permitted for the shop" do
        let!(:enterprise_relationship) { create(:enterprise_relationship, child: shop, parent: product.supplier, permissions_list: [:add_to_order_cycle]) }

        it "is available" do
          expect(service.available_variants).to include(variant)
        end
      end

      context "if the variant is involved in an exchange" do
        let!(:order_cycle) { create(:simple_order_cycle, coordinator: shop) }
        let!(:schedule) { create(:schedule, order_cycles: [order_cycle]) }

        context "if it is an incoming exchange where the shop is the receiver" do
          let!(:incoming_exchange) { order_cycle.exchanges.create(sender: product.supplier, receiver: shop, incoming: true, variants: [variant]) }

          it "is unavailable" do
            expect(service.available_variants).to_not include(variant)
          end
        end

        context "if it is an outgoing exchange where the shop is the receiver" do
          let!(:outgoing_exchange) { order_cycle.exchanges.create(sender: product.supplier, receiver: shop, incoming: false, variants: [variant]) }

          it "is available" do
            expect(service.available_variants).to include(variant)
          end
        end
      end

      context "if the variant is unrelated" do
        it "is unavailable" do
          expect(service.available_variants).to_not include(variant)
        end
      end
    end

    describe "availability of variants in open and upcoming order cycles" do
      let!(:shop) { create(:enterprise) }
      let!(:product) { create(:product) }
      let!(:variant) { product.variants.first }
      let!(:schedule) { create(:schedule) }

      let(:service) { described_class.new(shop) }

      context "if the variant is involved in an exchange" do
        let!(:order_cycle) { create(:simple_order_cycle, coordinator: shop) }
        let!(:schedule) { create(:schedule, order_cycles: [order_cycle]) }

        context "if it is an incoming exchange where the shop is the receiver" do
          let!(:incoming_exchange) { order_cycle.exchanges.create(sender: product.supplier, receiver: shop, incoming: true, variants: [variant]) }

          it "is unavailable" do
            expect(service).to_not be_available_in_open_and_upcoming_order_cycles(schedule, variant)
          end
        end

        context "if it is an outgoing exchange where the shop is the receiver" do
          let!(:outgoing_exchange) { order_cycle.exchanges.create(sender: product.supplier, receiver: shop, incoming: false, variants: [variant]) }

          it "is available" do
            expect(service).to be_available_in_open_and_upcoming_order_cycles(schedule, variant)
          end
        end
      end

      context "if the variant is unrelated" do
        it "is unavailable" do
          expect(service).to_not be_available_in_open_and_upcoming_order_cycles(schedule, variant)
        end
      end
    end
  end
end
