module Admin
  module Deposits
    class ViacoinsController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::Viacoin'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @viacoins = @viacoins.includes(:member).
          where('created_at > ?', start_at).
          order('id DESC')
      end

      def update
        @viacoin.accept! if @viacoin.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
