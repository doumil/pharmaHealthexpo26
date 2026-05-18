class ExhibitorsClass {
  int id;
  String title;
  String stand;
  String discriptions;
  String shortDiscriptions;
  String adress;
  String siteweb;
  String image;
  bool fav;
  bool star;





  ExhibitorsClass(this.id,this.title,this.stand, this.shortDiscriptions,this.adress, this.discriptions,this.siteweb,this.image,this.fav,this.star);
  factory ExhibitorsClass.fromJson(dynamic json) {
    return ExhibitorsClass(json['id']as int ,json['title'] as String,json['stand'] as String, json['discriptions'] as String,
        json['shortDiscriptions'] as String, json['adress'] as String,json['siteweb'] as String,json['image'] as String,json['fav'] as bool,json['star'] as bool);
  }
  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'title': title,
      'stand':stand,
      'discriptions': discriptions,
      'shortDiscriptions': shortDiscriptions,
      'adress': adress,
      'siteweb':siteweb,
      'image':image,
      'fav':fav,
      'star':star,

    };
  }
  @override
  String toString() {
    return 'id : $id ,title : $title,stand : $stand,discriptions : $discriptions,shortDiscriptions : $shortDiscriptions,adress : $adress,sitweb : $siteweb,image $image,favorite : $fav,star $star';
  }
}
