extends Node

var Brick = ResourceLoader.load("res://Materials/Brick.tres")
var Plaster = ResourceLoader.load("res://Materials/Plaster.tres")
var Wood = ResourceLoader.load("res://Materials/Wood.tres")


func _ready():
	_my_function()
		
func _my_function() -> void:
	$ModelHolder/Male/AnimationPlayer.current_animation = "mixamocom"
	$ModelHolder/Female/AnimationPlayer.current_animation = "mixamocom"
	await get_tree().create_timer(4).timeout
	_my_function()
	
func _on_bottom_bar_new_enviroment_from_chatgpt(json):
	if(json.avatar.gender == "male"):
		$ModelHolder/Female.visible = false
		$ModelHolder/Male.visible = true
	else:
		$ModelHolder/Female.visible = true
		$ModelHolder/Male.visible = false
	
	var color = Color.from_string(json.avatar.color,Color.AQUA)
	var new_material = StandardMaterial3D.new()
	new_material.set_albedo(color)
	$ModelHolder/Female/RootNode/Skeleton3D/Beta_Surface.material_override = new_material
	$ModelHolder/Male/RootNode/Skeleton3D/Alpha_Surface.material_override = new_material
	
	
	print("Materialing Wall",json.wall.material)
	if(json.wall.material == "Brick"):
		$BackWall.material_override = Brick as StandardMaterial3D
	if(json.wall.material == "Plaster"):
		$BackWall.material_override = Plaster as StandardMaterial3D
	if(json.wall.material == "Wood"):
		$BackWall.material_override = Wood as StandardMaterial3D
		
	print("Materialing Floor",json.floor.material)
	if(json.floor.material == "Brick"):
		$Floor.material_override = Brick as StandardMaterial3D
	if(json.floor.material == "Plaster"):
		$Floor.material_override = Plaster as StandardMaterial3D
	if(json.floor.material == "Wood"):
		$Floor.material_override = Wood as StandardMaterial3D
		
		
	print("Materialing Ceiling",json.ceiling.material)
	if(json.ceiling.material == "Brick"):
		$Ceiling.material_override = Brick as StandardMaterial3D
	if(json.ceiling.material == "Plaster"):
		$Ceiling.material_override = Plaster as StandardMaterial3D
	if(json.ceiling.material == "Wood"):
		$Ceiling.material_override = Wood as StandardMaterial3D
