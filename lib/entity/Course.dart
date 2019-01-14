class Course {
  final int primaryKey;
  final String prodId;
  final String prodName;
  final String logo;
  final String intro;
  final String course;
  final String area;
  final String prodFlag;
  final String prodType;
  final String price;
  final String realPrice;
  final int avgRating;
  final int isHomeREC;
  final int prodCenterRECIndex;
  final String prodCenterRECArea;
  final int isProdCenterREC;
  final int homeRECIndex;
  final String homeRECArea;
  final String preSaleBeginTime;
  final String preSaleEndTime;
  final String catName;
  final int initCount;
  final int saleCount;
  final int learnPeopleCount;
  final int hasGift;
  final int areaSort;
  final int isLiving;
  final String status;

  Course(
      {this.primaryKey,
      this.prodId,
      this.prodName,
      this.logo,
      this.intro,
      this.course,
      this.area,
      this.prodFlag,
      this.prodType,
      this.price,
      this.realPrice,
      this.avgRating,
      this.isHomeREC,
      this.prodCenterRECIndex,
      this.prodCenterRECArea,
      this.isProdCenterREC,
      this.homeRECIndex,
      this.homeRECArea,
      this.preSaleBeginTime,
      this.preSaleEndTime,
      this.catName,
      this.initCount,
      this.saleCount,
      this.learnPeopleCount,
      this.hasGift,
      this.areaSort,
      this.isLiving,
      this.status});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      primaryKey: json['ID'],
    );
  }
}
