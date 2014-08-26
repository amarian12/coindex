module Admin
  module Deposits
    class PeercoinsController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::Peercoin'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @peercoins = @peercoins.includes(:member).
          where('created_at > ?', start_at).
          order('id DESC')
      end

      def update
        @peercoin.accept! if @peercoin.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
