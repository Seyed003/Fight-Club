class_name StoryScript
extends RefCounted
## Parses a chapter screenplay (story/*.txt) into a list of steps.
##
## Format, one statement per line:
##   # comment
##   @command positional key=value ...      stage directions
##       fa: متن فارسی                       text for the command above
##       en: English text
##   speaker: متن فارسی                      a spoken line (Persian first)
##       en: English text
##   speaker#line_id: ...                    pin a voice-file id
##   @choice / @option <label> / @endchoice  a menu of options
##   @label name                             a jump target
##
## Spoken lines get automatic ids (ch01_001, ch01_002...) used to find
## voice recordings in assets/voice/<lang>/<id>.ogg.

var chapter_id := ""
var steps: Array = []
var labels: Dictionary = {}
var errors: Array = []


static func load_file(path: String) -> StoryScript:
	var s := StoryScript.new()
	s.chapter_id = path.get_file().get_basename().get_slice("_", 0)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		s.errors.append("Cannot open %s" % path)
		return s
	s.parse(f.get_as_text())
	return s


func parse(text: String) -> void:
	var lines := text.split("\n")
	var said := 0
	var cur: Variant = null
	var choice: Variant = null
	var option: Variant = null
	for i in lines.size():
		var raw: String = lines[i].replace("\r", "")
		var line := raw.strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var indented := raw.begins_with(" ") or raw.begins_with("\t")
		if indented and (line.begins_with("fa:") or line.begins_with("en:")):
			var lang := line.substr(0, 2)
			var txt := line.substr(3).strip_edges()
			var target: Variant = option if option != null else cur
			if target == null:
				errors.append("line %d: text with nothing to attach to" % (i + 1))
				continue
			target[lang] = txt
			continue
		if line.begins_with("@"):
			var parts := line.substr(1).split(" ", false)
			if parts.is_empty():
				continue
			var cmd := parts[0]
			var step := {"cmd": cmd, "args": [], "kv": {}, "line": i + 1}
			for j in range(1, parts.size()):
				var tok: String = parts[j]
				var eq := tok.find("=")
				if eq > 0:
					step["kv"][tok.substr(0, eq)] = tok.substr(eq + 1)
				else:
					step["args"].append(tok)
			match cmd:
				"choice":
					step["options"] = []
					choice = step
					option = null
					steps.append(step)
					cur = step
				"option":
					if choice == null:
						errors.append("line %d: @option outside @choice" % (i + 1))
						continue
					option = {"to": step["args"][0] if step["args"].size() > 0 else "", "kv": step["kv"], "fa": "", "en": ""}
					choice["options"].append(option)
				"endchoice":
					choice = null
					option = null
				"label":
					if step["args"].is_empty():
						errors.append("line %d: @label needs a name" % (i + 1))
					else:
						labels[step["args"][0]] = steps.size()
				_:
					option = null
					steps.append(step)
					cur = step
			continue
		var colon := line.find(":")
		if colon > 0 and not indented:
			var who := line.substr(0, colon).strip_edges()
			var id := ""
			var hash_at := who.find("#")
			if hash_at >= 0:
				id = who.substr(hash_at + 1)
				who = who.substr(0, hash_at)
			if _is_ident(who):
				said += 1
				if id == "":
					id = "%s_%03d" % [chapter_id, said]
				var st := {"cmd": "say", "who": who, "fa": line.substr(colon + 1).strip_edges(), "en": "", "id": id, "line": i + 1}
				steps.append(st)
				cur = st
				option = null
				continue
		errors.append("line %d: can't read: %s" % [i + 1, line])
	for st in steps:
		for key in ["goto", "if", "ifnot", "iflose", "ifwin"]:
			if st["cmd"] == key:
				var target: String = st["args"][-1] if st["args"].size() > 0 else ""
				if not labels.has(target):
					errors.append("line %d: unknown label %s" % [st["line"], target])
		if st["cmd"] == "choice":
			for opt in st["options"]:
				if opt["to"] != "" and not labels.has(opt["to"]):
					errors.append("line %d: unknown label %s" % [st["line"], opt["to"]])


static func _is_ident(s: String) -> bool:
	if s.is_empty():
		return false
	for ch in s:
		var c := ch.unicode_at(0)
		var ok := (c >= 97 and c <= 122) or (c >= 65 and c <= 90) or (c >= 48 and c <= 57) or ch == "_"
		if not ok:
			return false
	return true


## Every spoken line, for building a voice-acting sheet.
func lines() -> Array:
	var out: Array = []
	for st in steps:
		if st["cmd"] == "say":
			out.append(st)
	return out
