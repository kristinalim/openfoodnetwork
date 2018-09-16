module Api
  module Admin
    class SubscriptionLineItemSerializer < ActiveModel::Serializer
      attributes :id, :variant_id, :quantity, :description, :price_estimate, :available_in_open_and_upcoming_order_cycles

      def description
        "#{object.variant.product.name} - #{object.variant.full_name}"
      end

      def price_estimate
        object.price_estimate.andand.to_f || "?"
      end

      def available_in_open_and_upcoming_order_cycles
        OpenFoodNetwork::SubscriptionService.new(option_or_assigned_shop).available_in_open_and_upcoming_order_cycles?(option_or_assigned_schedule, object.variant)
      end

      private

      def option_or_assigned_shop
        @options[:shop] || object.subscription.shop
      end

      def option_or_assigned_schedule
        @options[:schedule] || object.subscription.schedule
      end
    end
  end
end
