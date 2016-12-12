class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :gci_unit
      t.string :name

      t.timestamps null: false
    end

    [
      ['1107','Louisville'],
      ['1007','Binghamton'],
      ['1532','Indiana Group'],
      ['1019','Cincy/MNCO'],
      ['1085','Sioux Falls'],
      ['1021','Ft Collins'],
      ['1026','Ft Myers'],
      ['1151','Jackson TN'],
      ['1171','Asbury'],
      ['1010','Burlington'],
      ['1052','Wilmington'],
      ['1099','Hattiesburg'],
      ['1098','Jackson MS'],
      ['1174','Morristown'],
      ['1065','Bridgewater'],
      ['1014','Appleton'],
      ['1042','Springfield'],
      ['1011','Reno'],
      ['1530','St George'],
      ['1056','Nashville'],
      ['1028','Brevard'],
      ['1528','Salisbury'],
      ['1033','Iowa City'],
      ['1150','Des Moines'],
      ['1040','Shreveport'],
      ['1076','St Cloud'],
      ['1008','Detroit'],
      ['1051','Lansing'],
      ['1136','Mountain Home'],
      ['1558','Tallahassee'],
      ['1070','Rochester'],
      ['1066','Poughkeepsie'],
      ['1030','Guam'],
      ['1074','Salem'],
      ['1078','Salinas'],
      ['1089','Visalia'],
      ['1125','Staunton'],
      ['1087','Tucson'],
      ['1084','Westchester'],
      ['1122','Asheville'],
      ['1120','Greenville'],
      ['1013','Cherry Hill'],
      ['1106','Vineland'],
      ['1082','Palm Springs'],
      ['1063','Pensacola'],
      ['1094','Great Falls'],
      ['1123','Montgomery'],
      ['8872','USA Today'],
      ['1278','Texas NM'],
      ['1287','Keystone'],
      ['1255','Corpus Christi']
    ].each do |site|
      Site.create(gci_unit: site[0], name: site[1])
    end
  end
end
