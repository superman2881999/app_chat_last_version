class StickerModal {
  String identifier;
  String name;
  String tray_image_file;
  List<Sticker> StickerPack;

  StickerModal(this.identifier,this.name,this.tray_image_file,[this.StickerPack]);

  factory StickerModal.fromJson(dynamic json){
    var stickerObjsJson = json['stickers'] as List;
    List<Sticker> _stickers = stickerObjsJson.map((stickerJson) => Sticker.fromJson(stickerJson)).toList();
    return StickerModal(json['identifier'] as String,json['name'] as String, json['tray_image_file'] as String,_stickers);
  }
}

class Sticker{
  String image_file;
  Sticker(this.image_file);

  factory Sticker.fromJson(dynamic json){
    return Sticker(json['image_file'] as String);
  }
}