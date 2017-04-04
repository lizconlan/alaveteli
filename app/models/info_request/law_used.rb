# -*- encoding : utf-8 -*-
class InfoRequest
  module LawUsed

    # Two sorts of laws for requests, FOI or EIR
    def self.readable_data
      { :foi => { :short => _('FOI'),
                  :full => _('Freedom of Information'),
                  :with_a => _('A Freedom of Information request'),
                  :act => _('Freedom of Information Act') },
        :eir => { :short => _('EIR'),
                  :full => _('Environmental Information Regulations'),
                  :with_a => _('An Environmental Information request'),
                  :act => _('Environmental Information Regulations') }
      }
    end

  end
end
