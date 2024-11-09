// ignore_for_file: prefer_const_constructors, must_be_immutable, no_leading_underscores_for_local_identifiers, unused_field, sort_child_properties_last, use_build_context_synchronously, prefer_interpolation_to_compose_strings, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_diaryfood_project/models/diaryfood.dart';
import 'package:my_diaryfood_project/services/call_api.dart';
import 'package:my_diaryfood_project/utils/env.dart';

class UpDelDiaryfoodUI extends StatefulWidget {
  Diaryfood? diaryfood;
  UpDelDiaryfoodUI({super.key, this.diaryfood});

  @override
  State<UpDelDiaryfoodUI> createState() => _UpDelDiaryfoodUIState();
}

class _UpDelDiaryfoodUIState extends State<UpDelDiaryfoodUI> {
  TextEditingController foodShopNameCtrl = TextEditingController(text: '');
  TextEditingController foodPayCtrl = TextEditingController(text: '');
  TextEditingController foodDateCtrl = TextEditingController(text: '');

  File? _imageSelected;

  String? _imageBase64Selected;

  int? meal = 1;

  String? _foodProvinceSelected = 'กรุงเทพมหานคร';

  String? _foodDateSelected;

  //ประกาศ/สร้างตัวแปรเพื่อเก็บข้อมูลรายการที่จะเอาไปใช้กับ DropdownButton
  List<DropdownMenuItem<String>> provinceItems = [
    'กรุงเทพมหานคร',
    'กระบี่',
    'กาญจนบุรี',
    'กาฬสินธุ์',
    'กำแพงเพชร',
    'ขอนแก่น',
    'จันทบุรี',
    'ฉะเชิงเทรา',
    'ชลบุรี',
    'ชัยนาท',
    'ชัยภูมิ',
    'ชุมพร',
    'เชียงราย',
    'เชียงใหม่',
    'ตรัง',
    'ตราด',
    'ตาก',
    'นครนายก',
    'นครปฐม',
    'นครพนม',
    'นครราชสีมา',
    'นครศรีธรรมราช',
    'นครสวรรค์',
    'นนทบุรี',
    'นราธิวาส',
    'น่าน',
    'บึงกาฬ',
    'บุรีรัมย์',
    'ปทุมธานี',
    'ประจวบคีรีขันธ์',
    'ปราจีนบุรี',
    'ปัตตานี',
    'พระนครศรีอยุธยา',
    'พะเยา',
    'พังงา',
    'พัทลุง',
    'พิจิตร',
    'พิษณุโลก',
    'เพชรบุรี',
    'เพชรบูรณ์',
    'แพร่',
    'ภูเก็ต',
    'มหาสารคาม',
    'มุกดาหาร',
    'แม่ฮ่องสอน',
    'ยโสธร',
    'ยะลา',
    'ร้อยเอ็ด',
    'ระนอง',
    'ระยอง',
    'ราชบุรี',
    'ลพบุรี',
    'ลำปาง',
    'ลำพูน',
    'เลย',
    'ศรีสะเกษ',
    'สกลนคร',
    'สงขลา',
    'สตูล',
    'สมุทรปราการ',
    'สมุทรสงคราม',
    'สมุทรสาคร',
    'สระแก้ว',
    'สระบุรี',
    'สิงห์บุรี',
    'สุโขทัย',
    'สุพรรณบุรี',
    'สุราษฎร์ธานี',
    'สุรินทร์',
    'หนองคาย',
    'หนองบัวลำภู',
    'อ่างทอง',
    'อำนาจเจริญ',
    'อุดรธานี',
    'อุตรดิตถ์',
    'อุทัยธานี',
    'อุบลราชธานี'
  ]
      .map((e) => DropdownMenuItem<String>(
            value: e,
            child: Text(e),
          ))
      .toList();

  String? _foodLat;
  String? _foodLng;

  Position? _currentPosition;

  Future<Position> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getCurrentLocation() async {
  Position position = await _determinePosition();
  if (mounted) {
    setState(() {
      _currentPosition = position;
      _foodLat = position.latitude.toString();
      _foodLng = position.longitude.toString();
    });
  }
}


  Future<void> _opencamera() async {
    final XFile? _picker = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (_picker != null) {
      setState(() {
        _imageSelected = File(_picker.path);
        _imageBase64Selected = base64Encode(_imageSelected!.readAsBytesSync());
      });
    }
  }

  Future<void> _openGallery() async {
    final XFile? _picker = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (_picker != null) {
      setState(() {
        _imageSelected = File(_picker.path);
        _imageBase64Selected = base64Encode(_imageSelected!.readAsBytesSync());
      });
    }
  }

  Future<void> _openCalendar() async {
    final DateTime? _picker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (_picker != null) {
      setState(() {
        _foodDateSelected = _picker.toString().substring(0, 10);
        foodDateCtrl.text = convertToThaiDate(_picker);
      });
    }
  }

//เมธอดแปลงวันที่แบบสากล (ปี ค.ศ.-เดือน ตัวเลข-วัน ตัวเลข) ให้เป็นวันที่แบบไทย (วัน เดือน ปี)
  //                             2023-11-25
  convertToThaiDate(date) {
    String day = date.toString().substring(8, 10);
    String year = (int.parse(date.toString().substring(0, 4)) + 543).toString();
    String month = '';
    int monthTemp = int.parse(date.toString().substring(5, 7));
    switch (monthTemp) {
      case 1:
        month = 'มกราคม';
        break;
      case 2:
        month = 'กุมภาพันธ์';
        break;
      case 3:
        month = 'มีนาคม';
        break;
      case 4:
        month = 'เมษายน';
        break;
      case 5:
        month = 'พฤษภาคม';
        break;
      case 6:
        month = 'มิถุนายน';
        break;
      case 7:
        month = 'กรกฎาคม';
        break;
      case 8:
        month = 'สิงหาคม';
        break;
      case 9:
        month = 'กันยายน';
        break;
      case 10:
        month = 'ตุลาคม';
        break;
      case 11:
        month = 'พฤศจิกายน';
        break;
      default:
        month = 'ธันวาคม';
    }

    return int.parse(day).toString() + ' ' + month + ' ' + year;
  }

  showWaringDialog(context, msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'คำเตือน',
          ),
        ),
        content: Text(
          msg,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'ตกลง',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future showCompleteDialog(context, msg) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'ผลการทำงาน',
          ),
        ),
        content: Text(
          msg,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'ตกลง',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _getCurrentLocation();

    foodShopNameCtrl.text = widget.diaryfood!.foodShopname!;
    foodPayCtrl.text = widget.diaryfood!.foodPay!;
    meal = int.parse(widget.diaryfood!.foodMeal!);
    foodDateCtrl.text = widget.diaryfood!.foodDate!;
    _foodProvinceSelected = widget.diaryfood!.foodProvince!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'แก้ไข/ลบ บันทึกการกิน',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.075,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                      border: Border.all(width: 4, color: Colors.green),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _imageSelected == null
                            ? NetworkImage(
                                '${Env.hostName}/mydiaryfood/picupload/food/${widget.diaryfood!.foodImage}',
                              )
                            : FileImage(_imageSelected!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              onTap: () {
                                _opencamera()
                                    .then((value) => Navigator.pop(context));
                              },
                              leading: Icon(
                                Icons.camera_alt,
                                color: Colors.red,
                              ),
                              title: Text(
                                'Open Camera...',
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                              height: 5.0,
                            ),
                            ListTile(
                              onTap: () {
                                _openGallery()
                                    .then((value) => Navigator.pop(context));
                              },
                              leading: Icon(
                                Icons.browse_gallery,
                                color: Colors.blue,
                              ),
                              title: Text(
                                'Open Gallery...',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ร้านอาหาร',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  top: MediaQuery.of(context).size.height * 0.015,
                ),
                child: TextField(
                  controller: foodShopNameCtrl,
                  decoration: InputDecoration(
                    hintText: 'ป้อนชื่อร้านอาหาร',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  top: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ค่าใช้จ่าย',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  top: MediaQuery.of(context).size.height * 0.015,
                ),
                child: TextField(
                  controller: foodPayCtrl,
                  decoration: InputDecoration(
                    hintText: 'ป้อนค่าใช้จ่าย',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  top: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'อาหารมื้อ',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    onChanged: (int? value) {
                      setState(() {
                        meal = value;
                      });
                    },
                    value: 1,
                    groupValue: meal,
                    activeColor: Colors.green,
                  ),
                  Text(
                    'เช้า',
                  ),
                  Radio(
                    onChanged: (int? value) {
                      setState(() {
                        meal = value;
                      });
                    },
                    value: 2,
                    groupValue: meal,
                    activeColor: Colors.green,
                  ),
                  Text(
                    'กลางวัน',
                  ),
                  Radio(
                    onChanged: (int? value) {
                      setState(() {
                        meal = value;
                      });
                    },
                    value: 3,
                    groupValue: meal,
                    activeColor: Colors.green,
                  ),
                  Text(
                    'เย็น',
                  ),
                  Radio(
                    onChanged: (int? value) {
                      setState(() {
                        meal = value;
                      });
                    },
                    value: 4,
                    groupValue: meal,
                    activeColor: Colors.green,
                  ),
                  Text(
                    'ว่าง',
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  top: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'วันที่กิน',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  top: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: foodDateCtrl,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'เลือกวันที่',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _openCalendar();
                      },
                      icon: Icon(
                        Icons.calendar_month,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  top: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'จังหวัด',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  top: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Container(
                  padding: EdgeInsets.all(9.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                    ),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    items: provinceItems,
                    onChanged: (String? value) {
                      setState(() {
                        _foodProvinceSelected = value!;
                      });
                    },
                    value: _foodProvinceSelected,
                    underline: SizedBox(),
                    style: TextStyle(
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              ElevatedButton(
                onPressed: () {
                  if(foodShopNameCtrl.text.isEmpty){
                    showWaringDialog(context, 'กรุณาใส่ชื่อร้าน');
                  }else if(foodPayCtrl.text.isEmpty){
                    showWaringDialog(context, 'กรุณาใส่ราคา');
                  }else{
                    Diaryfood diaryfood;
                    if(_imageSelected == null){
                      diaryfood = Diaryfood(
                        foodId: widget.diaryfood!.foodId,
                        foodShopname: foodShopNameCtrl.text,
                        foodPay: foodPayCtrl.text,
                        foodMeal: meal.toString(),
                        foodDate: foodDateCtrl.text,  
                        foodProvince: _foodProvinceSelected,
                        foodLat: widget.diaryfood!.foodLat,
                        foodLng: widget.diaryfood!.foodLng,
                        memId: widget.diaryfood!.memId,
                      );
                    }else{
                      diaryfood = Diaryfood(
                        foodId: widget.diaryfood!.foodId,
                        foodShopname: foodShopNameCtrl.text,
                        foodPay: foodPayCtrl.text,
                        foodMeal: meal.toString(),
                        foodDate: foodDateCtrl.text,  
                        foodProvince: _foodProvinceSelected,
                        foodLat: widget.diaryfood!.foodLat,
                        foodLng: widget.diaryfood!.foodLng,
                        memId: widget.diaryfood!.memId,
                        foodImage: _imageBase64Selected,);
                    }
                    CallAPI.callUpdateDiaryfoodAPI(diaryfood).then((value) {
                    if (value.message == '1') {
                      showCompleteDialog(context, 'แก้ไขบันทึกการกินสําเร็จ')
                          .then((value) {
                        Navigator.pop(context);
                      });
                    } else if (value.message == '0') {
                      showWaringDialog(context, 'แก้ไขบันทึกการกินไม่สําเร็จ');
                    }
                  });
                  }
                },
                child: Text(
                  'แก้ไขบันทึกการกิน',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  fixedSize: Size(
                    MediaQuery.of(context).size.width * 0.8,
                    MediaQuery.of(context).size.height * 0.07,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              ElevatedButton(
                onPressed: () {
                  Diaryfood diaryfood = Diaryfood(
                    foodId: widget.diaryfood!.foodId,
                  );
                  CallAPI.callDeleteDiaryfoodAPI(diaryfood).then((value) {
                    if (value.message == '1') {
                      showCompleteDialog(context, 'ลบบันทึกการกินสําเร็จ')
                          .then((value) {
                        Navigator.pop(context);
                      });
                    } else if (value.message == '0') {
                      showWaringDialog(context, 'ลบบันทึกการกินไม่สําเร็จ');
                    }
                  });
                },
                child: Text(
                  'ลบบันทึกการกิน',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  fixedSize: Size(
                    MediaQuery.of(context).size.width * 0.8,
                    MediaQuery.of(context).size.height * 0.07,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
