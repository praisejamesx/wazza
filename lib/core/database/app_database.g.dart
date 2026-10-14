// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChatsTable extends Chats with TableInfo<$ChatsTable, Chat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _messageCountMeta =
      const VerificationMeta('messageCount');
  @override
  late final GeneratedColumn<int> messageCount = GeneratedColumn<int>(
      'message_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _systemPromptMeta =
      const VerificationMeta('systemPrompt');
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
      'system_prompt', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modelIdMeta =
      const VerificationMeta('modelId');
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
      'model_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<int> isPinned = GeneratedColumn<int>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, createdAt, messageCount, systemPrompt, modelId, isPinned];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(Insertable<Chat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('message_count')) {
      context.handle(
          _messageCountMeta,
          messageCount.isAcceptableOrUnknown(
              data['message_count']!, _messageCountMeta));
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
          _systemPromptMeta,
          systemPrompt.isAcceptableOrUnknown(
              data['system_prompt']!, _systemPromptMeta));
    }
    if (data.containsKey('model_id')) {
      context.handle(_modelIdMeta,
          modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chat(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      messageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_count'])!,
      systemPrompt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}system_prompt']),
      modelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_id']),
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_pinned'])!,
    );
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(attachedDatabase, alias);
  }
}

class Chat extends DataClass implements Insertable<Chat> {
  final String id;
  final String? title;
  final int createdAt;
  final int messageCount;
  final String? systemPrompt;
  final String? modelId;
  final int isPinned;
  const Chat(
      {required this.id,
      this.title,
      required this.createdAt,
      required this.messageCount,
      this.systemPrompt,
      this.modelId,
      required this.isPinned});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['message_count'] = Variable<int>(messageCount);
    if (!nullToAbsent || systemPrompt != null) {
      map['system_prompt'] = Variable<String>(systemPrompt);
    }
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<String>(modelId);
    }
    map['is_pinned'] = Variable<int>(isPinned);
    return map;
  }

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      id: Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      createdAt: Value(createdAt),
      messageCount: Value(messageCount),
      systemPrompt: systemPrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(systemPrompt),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      isPinned: Value(isPinned),
    );
  }

  factory Chat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chat(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      messageCount: serializer.fromJson<int>(json['messageCount']),
      systemPrompt: serializer.fromJson<String?>(json['systemPrompt']),
      modelId: serializer.fromJson<String?>(json['modelId']),
      isPinned: serializer.fromJson<int>(json['isPinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'createdAt': serializer.toJson<int>(createdAt),
      'messageCount': serializer.toJson<int>(messageCount),
      'systemPrompt': serializer.toJson<String?>(systemPrompt),
      'modelId': serializer.toJson<String?>(modelId),
      'isPinned': serializer.toJson<int>(isPinned),
    };
  }

  Chat copyWith(
          {String? id,
          Value<String?> title = const Value.absent(),
          int? createdAt,
          int? messageCount,
          Value<String?> systemPrompt = const Value.absent(),
          Value<String?> modelId = const Value.absent(),
          int? isPinned}) =>
      Chat(
        id: id ?? this.id,
        title: title.present ? title.value : this.title,
        createdAt: createdAt ?? this.createdAt,
        messageCount: messageCount ?? this.messageCount,
        systemPrompt:
            systemPrompt.present ? systemPrompt.value : this.systemPrompt,
        modelId: modelId.present ? modelId.value : this.modelId,
        isPinned: isPinned ?? this.isPinned,
      );
  Chat copyWithCompanion(ChatsCompanion data) {
    return Chat(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      messageCount: data.messageCount.present
          ? data.messageCount.value
          : this.messageCount,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chat(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('messageCount: $messageCount, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('modelId: $modelId, ')
          ..write('isPinned: $isPinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, createdAt, messageCount, systemPrompt, modelId, isPinned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chat &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.messageCount == this.messageCount &&
          other.systemPrompt == this.systemPrompt &&
          other.modelId == this.modelId &&
          other.isPinned == this.isPinned);
}

class ChatsCompanion extends UpdateCompanion<Chat> {
  final Value<String> id;
  final Value<String?> title;
  final Value<int> createdAt;
  final Value<int> messageCount;
  final Value<String?> systemPrompt;
  final Value<String?> modelId;
  final Value<int> isPinned;
  final Value<int> rowid;
  const ChatsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.modelId = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required int createdAt,
    this.messageCount = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.modelId = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt);
  static Insertable<Chat> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? createdAt,
    Expression<int>? messageCount,
    Expression<String>? systemPrompt,
    Expression<String>? modelId,
    Expression<int>? isPinned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (messageCount != null) 'message_count': messageCount,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (modelId != null) 'model_id': modelId,
      if (isPinned != null) 'is_pinned': isPinned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? title,
      Value<int>? createdAt,
      Value<int>? messageCount,
      Value<String?>? systemPrompt,
      Value<String?>? modelId,
      Value<int>? isPinned,
      Value<int>? rowid}) {
    return ChatsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      messageCount: messageCount ?? this.messageCount,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      modelId: modelId ?? this.modelId,
      isPinned: isPinned ?? this.isPinned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (messageCount.present) {
      map['message_count'] = Variable<int>(messageCount.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<int>(isPinned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('messageCount: $messageCount, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('modelId: $modelId, ')
          ..write('isPinned: $isPinned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
      'chat_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chats (id)'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isUserMeta = const VerificationMeta('isUser');
  @override
  late final GeneratedColumn<int> isUser = GeneratedColumn<int>(
      'is_user', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modelIdMeta =
      const VerificationMeta('modelId');
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
      'model_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, chatId, content, isUser, createdAt, imagePath, modelId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chat_id')) {
      context.handle(_chatIdMeta,
          chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta));
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_user')) {
      context.handle(_isUserMeta,
          isUser.isAcceptableOrUnknown(data['is_user']!, _isUserMeta));
    } else if (isInserting) {
      context.missing(_isUserMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('model_id')) {
      context.handle(_modelIdMeta,
          modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      chatId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chat_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      isUser: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_user'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      modelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_id']),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final String chatId;
  final String content;
  final int isUser;
  final int createdAt;
  final String? imagePath;
  final String? modelId;
  const Message(
      {required this.id,
      required this.chatId,
      required this.content,
      required this.isUser,
      required this.createdAt,
      this.imagePath,
      this.modelId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['content'] = Variable<String>(content);
    map['is_user'] = Variable<int>(isUser);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<String>(modelId);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      content: Value(content),
      isUser: Value(isUser),
      createdAt: Value(createdAt),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      content: serializer.fromJson<String>(json['content']),
      isUser: serializer.fromJson<int>(json['isUser']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      modelId: serializer.fromJson<String?>(json['modelId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chatId': serializer.toJson<String>(chatId),
      'content': serializer.toJson<String>(content),
      'isUser': serializer.toJson<int>(isUser),
      'createdAt': serializer.toJson<int>(createdAt),
      'imagePath': serializer.toJson<String?>(imagePath),
      'modelId': serializer.toJson<String?>(modelId),
    };
  }

  Message copyWith(
          {int? id,
          String? chatId,
          String? content,
          int? isUser,
          int? createdAt,
          Value<String?> imagePath = const Value.absent(),
          Value<String?> modelId = const Value.absent()}) =>
      Message(
        id: id ?? this.id,
        chatId: chatId ?? this.chatId,
        content: content ?? this.content,
        isUser: isUser ?? this.isUser,
        createdAt: createdAt ?? this.createdAt,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        modelId: modelId.present ? modelId.value : this.modelId,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      content: data.content.present ? data.content.value : this.content,
      isUser: data.isUser.present ? data.isUser.value : this.isUser,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('content: $content, ')
          ..write('isUser: $isUser, ')
          ..write('createdAt: $createdAt, ')
          ..write('imagePath: $imagePath, ')
          ..write('modelId: $modelId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, chatId, content, isUser, createdAt, imagePath, modelId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.content == this.content &&
          other.isUser == this.isUser &&
          other.createdAt == this.createdAt &&
          other.imagePath == this.imagePath &&
          other.modelId == this.modelId);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<String> chatId;
  final Value<String> content;
  final Value<int> isUser;
  final Value<int> createdAt;
  final Value<String?> imagePath;
  final Value<String?> modelId;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.content = const Value.absent(),
    this.isUser = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.modelId = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required String chatId,
    required String content,
    required int isUser,
    required int createdAt,
    this.imagePath = const Value.absent(),
    this.modelId = const Value.absent(),
  })  : chatId = Value(chatId),
        content = Value(content),
        isUser = Value(isUser),
        createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<String>? chatId,
    Expression<String>? content,
    Expression<int>? isUser,
    Expression<int>? createdAt,
    Expression<String>? imagePath,
    Expression<String>? modelId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (content != null) 'content': content,
      if (isUser != null) 'is_user': isUser,
      if (createdAt != null) 'created_at': createdAt,
      if (imagePath != null) 'image_path': imagePath,
      if (modelId != null) 'model_id': modelId,
    });
  }

  MessagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? chatId,
      Value<String>? content,
      Value<int>? isUser,
      Value<int>? createdAt,
      Value<String?>? imagePath,
      Value<String?>? modelId}) {
    return MessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      modelId: modelId ?? this.modelId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isUser.present) {
      map['is_user'] = Variable<int>(isUser.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('content: $content, ')
          ..write('isUser: $isUser, ')
          ..write('createdAt: $createdAt, ')
          ..write('imagePath: $imagePath, ')
          ..write('modelId: $modelId')
          ..write(')'))
        .toString();
  }
}

class $DownloadedModelsTable extends DownloadedModels
    with TableInfo<$DownloadedModelsTable, DownloadedModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeMbMeta = const VerificationMeta('sizeMb');
  @override
  late final GeneratedColumn<int> sizeMb = GeneratedColumn<int>(
      'size_mb', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantMeta = const VerificationMeta('quant');
  @override
  late final GeneratedColumn<String> quant = GeneratedColumn<String>(
      'quant', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _templateTypeMeta =
      const VerificationMeta('templateType');
  @override
  late final GeneratedColumn<String> templateType = GeneratedColumn<String>(
      'template_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bestForMeta =
      const VerificationMeta('bestFor');
  @override
  late final GeneratedColumn<String> bestFor = GeneratedColumn<String>(
      'best_for', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<int> isCustom = GeneratedColumn<int>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _discoveredAtMeta =
      const VerificationMeta('discoveredAt');
  @override
  late final GeneratedColumn<int> discoveredAt = GeneratedColumn<int>(
      'discovered_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeBytesMeta =
      const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
      'file_size_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fileHashMeta =
      const VerificationMeta('fileHash');
  @override
  late final GeneratedColumn<String> fileHash = GeneratedColumn<String>(
      'file_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastVerifiedMeta =
      const VerificationMeta('lastVerified');
  @override
  late final GeneratedColumn<int> lastVerified = GeneratedColumn<int>(
      'last_verified', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        sizeMb,
        quant,
        localPath,
        templateType,
        description,
        bestFor,
        isCustom,
        discoveredAt,
        fileSizeBytes,
        fileHash,
        lastVerified
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_models';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadedModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('size_mb')) {
      context.handle(_sizeMbMeta,
          sizeMb.isAcceptableOrUnknown(data['size_mb']!, _sizeMbMeta));
    } else if (isInserting) {
      context.missing(_sizeMbMeta);
    }
    if (data.containsKey('quant')) {
      context.handle(
          _quantMeta, quant.isAcceptableOrUnknown(data['quant']!, _quantMeta));
    } else if (isInserting) {
      context.missing(_quantMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('template_type')) {
      context.handle(
          _templateTypeMeta,
          templateType.isAcceptableOrUnknown(
              data['template_type']!, _templateTypeMeta));
    } else if (isInserting) {
      context.missing(_templateTypeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('best_for')) {
      context.handle(_bestForMeta,
          bestFor.isAcceptableOrUnknown(data['best_for']!, _bestForMeta));
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    if (data.containsKey('discovered_at')) {
      context.handle(
          _discoveredAtMeta,
          discoveredAt.isAcceptableOrUnknown(
              data['discovered_at']!, _discoveredAtMeta));
    } else if (isInserting) {
      context.missing(_discoveredAtMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
          _fileSizeBytesMeta,
          fileSizeBytes.isAcceptableOrUnknown(
              data['file_size_bytes']!, _fileSizeBytesMeta));
    }
    if (data.containsKey('file_hash')) {
      context.handle(_fileHashMeta,
          fileHash.isAcceptableOrUnknown(data['file_hash']!, _fileHashMeta));
    }
    if (data.containsKey('last_verified')) {
      context.handle(
          _lastVerifiedMeta,
          lastVerified.isAcceptableOrUnknown(
              data['last_verified']!, _lastVerifiedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadedModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedModel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sizeMb: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_mb'])!,
      quant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quant'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      templateType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_type'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      bestFor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}best_for']),
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_custom'])!,
      discoveredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}discovered_at'])!,
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes'])!,
      fileHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_hash']),
      lastVerified: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_verified']),
    );
  }

  @override
  $DownloadedModelsTable createAlias(String alias) {
    return $DownloadedModelsTable(attachedDatabase, alias);
  }
}

class DownloadedModel extends DataClass implements Insertable<DownloadedModel> {
  final String id;
  final String name;
  final int sizeMb;
  final String quant;
  final String localPath;
  final String templateType;
  final String? description;
  final String? bestFor;
  final int isCustom;
  final int discoveredAt;
  final int fileSizeBytes;
  final String? fileHash;
  final int? lastVerified;
  const DownloadedModel(
      {required this.id,
      required this.name,
      required this.sizeMb,
      required this.quant,
      required this.localPath,
      required this.templateType,
      this.description,
      this.bestFor,
      required this.isCustom,
      required this.discoveredAt,
      required this.fileSizeBytes,
      this.fileHash,
      this.lastVerified});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['size_mb'] = Variable<int>(sizeMb);
    map['quant'] = Variable<String>(quant);
    map['local_path'] = Variable<String>(localPath);
    map['template_type'] = Variable<String>(templateType);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || bestFor != null) {
      map['best_for'] = Variable<String>(bestFor);
    }
    map['is_custom'] = Variable<int>(isCustom);
    map['discovered_at'] = Variable<int>(discoveredAt);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    if (!nullToAbsent || fileHash != null) {
      map['file_hash'] = Variable<String>(fileHash);
    }
    if (!nullToAbsent || lastVerified != null) {
      map['last_verified'] = Variable<int>(lastVerified);
    }
    return map;
  }

  DownloadedModelsCompanion toCompanion(bool nullToAbsent) {
    return DownloadedModelsCompanion(
      id: Value(id),
      name: Value(name),
      sizeMb: Value(sizeMb),
      quant: Value(quant),
      localPath: Value(localPath),
      templateType: Value(templateType),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      bestFor: bestFor == null && nullToAbsent
          ? const Value.absent()
          : Value(bestFor),
      isCustom: Value(isCustom),
      discoveredAt: Value(discoveredAt),
      fileSizeBytes: Value(fileSizeBytes),
      fileHash: fileHash == null && nullToAbsent
          ? const Value.absent()
          : Value(fileHash),
      lastVerified: lastVerified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerified),
    );
  }

  factory DownloadedModel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedModel(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sizeMb: serializer.fromJson<int>(json['sizeMb']),
      quant: serializer.fromJson<String>(json['quant']),
      localPath: serializer.fromJson<String>(json['localPath']),
      templateType: serializer.fromJson<String>(json['templateType']),
      description: serializer.fromJson<String?>(json['description']),
      bestFor: serializer.fromJson<String?>(json['bestFor']),
      isCustom: serializer.fromJson<int>(json['isCustom']),
      discoveredAt: serializer.fromJson<int>(json['discoveredAt']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      fileHash: serializer.fromJson<String?>(json['fileHash']),
      lastVerified: serializer.fromJson<int?>(json['lastVerified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sizeMb': serializer.toJson<int>(sizeMb),
      'quant': serializer.toJson<String>(quant),
      'localPath': serializer.toJson<String>(localPath),
      'templateType': serializer.toJson<String>(templateType),
      'description': serializer.toJson<String?>(description),
      'bestFor': serializer.toJson<String?>(bestFor),
      'isCustom': serializer.toJson<int>(isCustom),
      'discoveredAt': serializer.toJson<int>(discoveredAt),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'fileHash': serializer.toJson<String?>(fileHash),
      'lastVerified': serializer.toJson<int?>(lastVerified),
    };
  }

  DownloadedModel copyWith(
          {String? id,
          String? name,
          int? sizeMb,
          String? quant,
          String? localPath,
          String? templateType,
          Value<String?> description = const Value.absent(),
          Value<String?> bestFor = const Value.absent(),
          int? isCustom,
          int? discoveredAt,
          int? fileSizeBytes,
          Value<String?> fileHash = const Value.absent(),
          Value<int?> lastVerified = const Value.absent()}) =>
      DownloadedModel(
        id: id ?? this.id,
        name: name ?? this.name,
        sizeMb: sizeMb ?? this.sizeMb,
        quant: quant ?? this.quant,
        localPath: localPath ?? this.localPath,
        templateType: templateType ?? this.templateType,
        description: description.present ? description.value : this.description,
        bestFor: bestFor.present ? bestFor.value : this.bestFor,
        isCustom: isCustom ?? this.isCustom,
        discoveredAt: discoveredAt ?? this.discoveredAt,
        fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
        fileHash: fileHash.present ? fileHash.value : this.fileHash,
        lastVerified:
            lastVerified.present ? lastVerified.value : this.lastVerified,
      );
  DownloadedModel copyWithCompanion(DownloadedModelsCompanion data) {
    return DownloadedModel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sizeMb: data.sizeMb.present ? data.sizeMb.value : this.sizeMb,
      quant: data.quant.present ? data.quant.value : this.quant,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      templateType: data.templateType.present
          ? data.templateType.value
          : this.templateType,
      description:
          data.description.present ? data.description.value : this.description,
      bestFor: data.bestFor.present ? data.bestFor.value : this.bestFor,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      discoveredAt: data.discoveredAt.present
          ? data.discoveredAt.value
          : this.discoveredAt,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      fileHash: data.fileHash.present ? data.fileHash.value : this.fileHash,
      lastVerified: data.lastVerified.present
          ? data.lastVerified.value
          : this.lastVerified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedModel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sizeMb: $sizeMb, ')
          ..write('quant: $quant, ')
          ..write('localPath: $localPath, ')
          ..write('templateType: $templateType, ')
          ..write('description: $description, ')
          ..write('bestFor: $bestFor, ')
          ..write('isCustom: $isCustom, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('fileHash: $fileHash, ')
          ..write('lastVerified: $lastVerified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      sizeMb,
      quant,
      localPath,
      templateType,
      description,
      bestFor,
      isCustom,
      discoveredAt,
      fileSizeBytes,
      fileHash,
      lastVerified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedModel &&
          other.id == this.id &&
          other.name == this.name &&
          other.sizeMb == this.sizeMb &&
          other.quant == this.quant &&
          other.localPath == this.localPath &&
          other.templateType == this.templateType &&
          other.description == this.description &&
          other.bestFor == this.bestFor &&
          other.isCustom == this.isCustom &&
          other.discoveredAt == this.discoveredAt &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.fileHash == this.fileHash &&
          other.lastVerified == this.lastVerified);
}

class DownloadedModelsCompanion extends UpdateCompanion<DownloadedModel> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sizeMb;
  final Value<String> quant;
  final Value<String> localPath;
  final Value<String> templateType;
  final Value<String?> description;
  final Value<String?> bestFor;
  final Value<int> isCustom;
  final Value<int> discoveredAt;
  final Value<int> fileSizeBytes;
  final Value<String?> fileHash;
  final Value<int?> lastVerified;
  final Value<int> rowid;
  const DownloadedModelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sizeMb = const Value.absent(),
    this.quant = const Value.absent(),
    this.localPath = const Value.absent(),
    this.templateType = const Value.absent(),
    this.description = const Value.absent(),
    this.bestFor = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.discoveredAt = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.fileHash = const Value.absent(),
    this.lastVerified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadedModelsCompanion.insert({
    required String id,
    required String name,
    required int sizeMb,
    required String quant,
    required String localPath,
    required String templateType,
    this.description = const Value.absent(),
    this.bestFor = const Value.absent(),
    this.isCustom = const Value.absent(),
    required int discoveredAt,
    this.fileSizeBytes = const Value.absent(),
    this.fileHash = const Value.absent(),
    this.lastVerified = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        sizeMb = Value(sizeMb),
        quant = Value(quant),
        localPath = Value(localPath),
        templateType = Value(templateType),
        discoveredAt = Value(discoveredAt);
  static Insertable<DownloadedModel> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sizeMb,
    Expression<String>? quant,
    Expression<String>? localPath,
    Expression<String>? templateType,
    Expression<String>? description,
    Expression<String>? bestFor,
    Expression<int>? isCustom,
    Expression<int>? discoveredAt,
    Expression<int>? fileSizeBytes,
    Expression<String>? fileHash,
    Expression<int>? lastVerified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sizeMb != null) 'size_mb': sizeMb,
      if (quant != null) 'quant': quant,
      if (localPath != null) 'local_path': localPath,
      if (templateType != null) 'template_type': templateType,
      if (description != null) 'description': description,
      if (bestFor != null) 'best_for': bestFor,
      if (isCustom != null) 'is_custom': isCustom,
      if (discoveredAt != null) 'discovered_at': discoveredAt,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (fileHash != null) 'file_hash': fileHash,
      if (lastVerified != null) 'last_verified': lastVerified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadedModelsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? sizeMb,
      Value<String>? quant,
      Value<String>? localPath,
      Value<String>? templateType,
      Value<String?>? description,
      Value<String?>? bestFor,
      Value<int>? isCustom,
      Value<int>? discoveredAt,
      Value<int>? fileSizeBytes,
      Value<String?>? fileHash,
      Value<int?>? lastVerified,
      Value<int>? rowid}) {
    return DownloadedModelsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sizeMb: sizeMb ?? this.sizeMb,
      quant: quant ?? this.quant,
      localPath: localPath ?? this.localPath,
      templateType: templateType ?? this.templateType,
      description: description ?? this.description,
      bestFor: bestFor ?? this.bestFor,
      isCustom: isCustom ?? this.isCustom,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      fileHash: fileHash ?? this.fileHash,
      lastVerified: lastVerified ?? this.lastVerified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sizeMb.present) {
      map['size_mb'] = Variable<int>(sizeMb.value);
    }
    if (quant.present) {
      map['quant'] = Variable<String>(quant.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (templateType.present) {
      map['template_type'] = Variable<String>(templateType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (bestFor.present) {
      map['best_for'] = Variable<String>(bestFor.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<int>(isCustom.value);
    }
    if (discoveredAt.present) {
      map['discovered_at'] = Variable<int>(discoveredAt.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (fileHash.present) {
      map['file_hash'] = Variable<String>(fileHash.value);
    }
    if (lastVerified.present) {
      map['last_verified'] = Variable<int>(lastVerified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedModelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sizeMb: $sizeMb, ')
          ..write('quant: $quant, ')
          ..write('localPath: $localPath, ')
          ..write('templateType: $templateType, ')
          ..write('description: $description, ')
          ..write('bestFor: $bestFor, ')
          ..write('isCustom: $isCustom, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('fileHash: $fileHash, ')
          ..write('lastVerified: $lastVerified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsageLogsTable extends UsageLogs
    with TableInfo<$UsageLogsTable, UsageLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsageLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('message'));
  @override
  List<GeneratedColumn> get $columns => [id, timestamp, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usage_logs';
  @override
  VerificationContext validateIntegrity(Insertable<UsageLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsageLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsageLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
    );
  }

  @override
  $UsageLogsTable createAlias(String alias) {
    return $UsageLogsTable(attachedDatabase, alias);
  }
}

class UsageLog extends DataClass implements Insertable<UsageLog> {
  final int id;
  final int timestamp;
  final String type;
  const UsageLog(
      {required this.id, required this.timestamp, required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<int>(timestamp);
    map['type'] = Variable<String>(type);
    return map;
  }

  UsageLogsCompanion toCompanion(bool nullToAbsent) {
    return UsageLogsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      type: Value(type),
    );
  }

  factory UsageLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsageLog(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<int>(timestamp),
      'type': serializer.toJson<String>(type),
    };
  }

  UsageLog copyWith({int? id, int? timestamp, String? type}) => UsageLog(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        type: type ?? this.type,
      );
  UsageLog copyWithCompanion(UsageLogsCompanion data) {
    return UsageLog(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsageLog(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timestamp, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageLog &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.type == this.type);
}

class UsageLogsCompanion extends UpdateCompanion<UsageLog> {
  final Value<int> id;
  final Value<int> timestamp;
  final Value<String> type;
  const UsageLogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.type = const Value.absent(),
  });
  UsageLogsCompanion.insert({
    this.id = const Value.absent(),
    required int timestamp,
    this.type = const Value.absent(),
  }) : timestamp = Value(timestamp);
  static Insertable<UsageLog> custom({
    Expression<int>? id,
    Expression<int>? timestamp,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (type != null) 'type': type,
    });
  }

  UsageLogsCompanion copyWith(
      {Value<int>? id, Value<int>? timestamp, Value<String>? type}) {
    return UsageLogsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsageLogsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $ModelCacheTable extends ModelCache
    with TableInfo<$ModelCacheTable, ModelCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileHashMeta =
      const VerificationMeta('fileHash');
  @override
  late final GeneratedColumn<String> fileHash = GeneratedColumn<String>(
      'file_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<int> lastModified = GeneratedColumn<int>(
      'last_modified', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _discoveredAtMeta =
      const VerificationMeta('discoveredAt');
  @override
  late final GeneratedColumn<int> discoveredAt = GeneratedColumn<int>(
      'discovered_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [filePath, fileHash, lastModified, discoveredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'model_cache';
  @override
  VerificationContext validateIntegrity(Insertable<ModelCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_hash')) {
      context.handle(_fileHashMeta,
          fileHash.isAcceptableOrUnknown(data['file_hash']!, _fileHashMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('discovered_at')) {
      context.handle(
          _discoveredAtMeta,
          discoveredAt.isAcceptableOrUnknown(
              data['discovered_at']!, _discoveredAtMeta));
    } else if (isInserting) {
      context.missing(_discoveredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {filePath};
  @override
  ModelCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelCacheData(
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      fileHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_hash']),
      lastModified: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_modified'])!,
      discoveredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}discovered_at'])!,
    );
  }

  @override
  $ModelCacheTable createAlias(String alias) {
    return $ModelCacheTable(attachedDatabase, alias);
  }
}

class ModelCacheData extends DataClass implements Insertable<ModelCacheData> {
  final String filePath;
  final String? fileHash;
  final int lastModified;
  final int discoveredAt;
  const ModelCacheData(
      {required this.filePath,
      this.fileHash,
      required this.lastModified,
      required this.discoveredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || fileHash != null) {
      map['file_hash'] = Variable<String>(fileHash);
    }
    map['last_modified'] = Variable<int>(lastModified);
    map['discovered_at'] = Variable<int>(discoveredAt);
    return map;
  }

  ModelCacheCompanion toCompanion(bool nullToAbsent) {
    return ModelCacheCompanion(
      filePath: Value(filePath),
      fileHash: fileHash == null && nullToAbsent
          ? const Value.absent()
          : Value(fileHash),
      lastModified: Value(lastModified),
      discoveredAt: Value(discoveredAt),
    );
  }

  factory ModelCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelCacheData(
      filePath: serializer.fromJson<String>(json['filePath']),
      fileHash: serializer.fromJson<String?>(json['fileHash']),
      lastModified: serializer.fromJson<int>(json['lastModified']),
      discoveredAt: serializer.fromJson<int>(json['discoveredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'filePath': serializer.toJson<String>(filePath),
      'fileHash': serializer.toJson<String?>(fileHash),
      'lastModified': serializer.toJson<int>(lastModified),
      'discoveredAt': serializer.toJson<int>(discoveredAt),
    };
  }

  ModelCacheData copyWith(
          {String? filePath,
          Value<String?> fileHash = const Value.absent(),
          int? lastModified,
          int? discoveredAt}) =>
      ModelCacheData(
        filePath: filePath ?? this.filePath,
        fileHash: fileHash.present ? fileHash.value : this.fileHash,
        lastModified: lastModified ?? this.lastModified,
        discoveredAt: discoveredAt ?? this.discoveredAt,
      );
  ModelCacheData copyWithCompanion(ModelCacheCompanion data) {
    return ModelCacheData(
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileHash: data.fileHash.present ? data.fileHash.value : this.fileHash,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      discoveredAt: data.discoveredAt.present
          ? data.discoveredAt.value
          : this.discoveredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModelCacheData(')
          ..write('filePath: $filePath, ')
          ..write('fileHash: $fileHash, ')
          ..write('lastModified: $lastModified, ')
          ..write('discoveredAt: $discoveredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(filePath, fileHash, lastModified, discoveredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelCacheData &&
          other.filePath == this.filePath &&
          other.fileHash == this.fileHash &&
          other.lastModified == this.lastModified &&
          other.discoveredAt == this.discoveredAt);
}

class ModelCacheCompanion extends UpdateCompanion<ModelCacheData> {
  final Value<String> filePath;
  final Value<String?> fileHash;
  final Value<int> lastModified;
  final Value<int> discoveredAt;
  final Value<int> rowid;
  const ModelCacheCompanion({
    this.filePath = const Value.absent(),
    this.fileHash = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.discoveredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModelCacheCompanion.insert({
    required String filePath,
    this.fileHash = const Value.absent(),
    required int lastModified,
    required int discoveredAt,
    this.rowid = const Value.absent(),
  })  : filePath = Value(filePath),
        lastModified = Value(lastModified),
        discoveredAt = Value(discoveredAt);
  static Insertable<ModelCacheData> custom({
    Expression<String>? filePath,
    Expression<String>? fileHash,
    Expression<int>? lastModified,
    Expression<int>? discoveredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (filePath != null) 'file_path': filePath,
      if (fileHash != null) 'file_hash': fileHash,
      if (lastModified != null) 'last_modified': lastModified,
      if (discoveredAt != null) 'discovered_at': discoveredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModelCacheCompanion copyWith(
      {Value<String>? filePath,
      Value<String?>? fileHash,
      Value<int>? lastModified,
      Value<int>? discoveredAt,
      Value<int>? rowid}) {
    return ModelCacheCompanion(
      filePath: filePath ?? this.filePath,
      fileHash: fileHash ?? this.fileHash,
      lastModified: lastModified ?? this.lastModified,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileHash.present) {
      map['file_hash'] = Variable<String>(fileHash.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<int>(lastModified.value);
    }
    if (discoveredAt.present) {
      map['discovered_at'] = Variable<int>(discoveredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelCacheCompanion(')
          ..write('filePath: $filePath, ')
          ..write('fileHash: $fileHash, ')
          ..write('lastModified: $lastModified, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AutomationFlowsTable extends AutomationFlows
    with TableInfo<$AutomationFlowsTable, AutomationFlow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AutomationFlowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _triggerTypeMeta =
      const VerificationMeta('triggerType');
  @override
  late final GeneratedColumn<String> triggerType = GeneratedColumn<String>(
      'trigger_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _triggerConfigMeta =
      const VerificationMeta('triggerConfig');
  @override
  late final GeneratedColumn<String> triggerConfig = GeneratedColumn<String>(
      'trigger_config', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
      'steps', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<int> isEnabled = GeneratedColumn<int>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastExecutedAtMeta =
      const VerificationMeta('lastExecutedAt');
  @override
  late final GeneratedColumn<int> lastExecutedAt = GeneratedColumn<int>(
      'last_executed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastStatusMeta =
      const VerificationMeta('lastStatus');
  @override
  late final GeneratedColumn<String> lastStatus = GeneratedColumn<String>(
      'last_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        triggerType,
        triggerConfig,
        steps,
        isEnabled,
        createdAt,
        lastExecutedAt,
        lastStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'automation_flows';
  @override
  VerificationContext validateIntegrity(Insertable<AutomationFlow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('trigger_type')) {
      context.handle(
          _triggerTypeMeta,
          triggerType.isAcceptableOrUnknown(
              data['trigger_type']!, _triggerTypeMeta));
    } else if (isInserting) {
      context.missing(_triggerTypeMeta);
    }
    if (data.containsKey('trigger_config')) {
      context.handle(
          _triggerConfigMeta,
          triggerConfig.isAcceptableOrUnknown(
              data['trigger_config']!, _triggerConfigMeta));
    }
    if (data.containsKey('steps')) {
      context.handle(
          _stepsMeta, steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta));
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_executed_at')) {
      context.handle(
          _lastExecutedAtMeta,
          lastExecutedAt.isAcceptableOrUnknown(
              data['last_executed_at']!, _lastExecutedAtMeta));
    }
    if (data.containsKey('last_status')) {
      context.handle(
          _lastStatusMeta,
          lastStatus.isAcceptableOrUnknown(
              data['last_status']!, _lastStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AutomationFlow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AutomationFlow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      triggerType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger_type'])!,
      triggerConfig: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger_config']),
      steps: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}steps'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      lastExecutedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_executed_at']),
      lastStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_status']),
    );
  }

  @override
  $AutomationFlowsTable createAlias(String alias) {
    return $AutomationFlowsTable(attachedDatabase, alias);
  }
}

class AutomationFlow extends DataClass implements Insertable<AutomationFlow> {
  final String id;
  final String name;
  final String? description;
  final String triggerType;
  final String? triggerConfig;
  final String steps;
  final int isEnabled;
  final int createdAt;
  final int? lastExecutedAt;
  final String? lastStatus;
  const AutomationFlow(
      {required this.id,
      required this.name,
      this.description,
      required this.triggerType,
      this.triggerConfig,
      required this.steps,
      required this.isEnabled,
      required this.createdAt,
      this.lastExecutedAt,
      this.lastStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['trigger_type'] = Variable<String>(triggerType);
    if (!nullToAbsent || triggerConfig != null) {
      map['trigger_config'] = Variable<String>(triggerConfig);
    }
    map['steps'] = Variable<String>(steps);
    map['is_enabled'] = Variable<int>(isEnabled);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || lastExecutedAt != null) {
      map['last_executed_at'] = Variable<int>(lastExecutedAt);
    }
    if (!nullToAbsent || lastStatus != null) {
      map['last_status'] = Variable<String>(lastStatus);
    }
    return map;
  }

  AutomationFlowsCompanion toCompanion(bool nullToAbsent) {
    return AutomationFlowsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      triggerType: Value(triggerType),
      triggerConfig: triggerConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(triggerConfig),
      steps: Value(steps),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      lastExecutedAt: lastExecutedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastExecutedAt),
      lastStatus: lastStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStatus),
    );
  }

  factory AutomationFlow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AutomationFlow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      triggerType: serializer.fromJson<String>(json['triggerType']),
      triggerConfig: serializer.fromJson<String?>(json['triggerConfig']),
      steps: serializer.fromJson<String>(json['steps']),
      isEnabled: serializer.fromJson<int>(json['isEnabled']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastExecutedAt: serializer.fromJson<int?>(json['lastExecutedAt']),
      lastStatus: serializer.fromJson<String?>(json['lastStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'triggerType': serializer.toJson<String>(triggerType),
      'triggerConfig': serializer.toJson<String?>(triggerConfig),
      'steps': serializer.toJson<String>(steps),
      'isEnabled': serializer.toJson<int>(isEnabled),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastExecutedAt': serializer.toJson<int?>(lastExecutedAt),
      'lastStatus': serializer.toJson<String?>(lastStatus),
    };
  }

  AutomationFlow copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? triggerType,
          Value<String?> triggerConfig = const Value.absent(),
          String? steps,
          int? isEnabled,
          int? createdAt,
          Value<int?> lastExecutedAt = const Value.absent(),
          Value<String?> lastStatus = const Value.absent()}) =>
      AutomationFlow(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        triggerType: triggerType ?? this.triggerType,
        triggerConfig:
            triggerConfig.present ? triggerConfig.value : this.triggerConfig,
        steps: steps ?? this.steps,
        isEnabled: isEnabled ?? this.isEnabled,
        createdAt: createdAt ?? this.createdAt,
        lastExecutedAt:
            lastExecutedAt.present ? lastExecutedAt.value : this.lastExecutedAt,
        lastStatus: lastStatus.present ? lastStatus.value : this.lastStatus,
      );
  AutomationFlow copyWithCompanion(AutomationFlowsCompanion data) {
    return AutomationFlow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      triggerType:
          data.triggerType.present ? data.triggerType.value : this.triggerType,
      triggerConfig: data.triggerConfig.present
          ? data.triggerConfig.value
          : this.triggerConfig,
      steps: data.steps.present ? data.steps.value : this.steps,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastExecutedAt: data.lastExecutedAt.present
          ? data.lastExecutedAt.value
          : this.lastExecutedAt,
      lastStatus:
          data.lastStatus.present ? data.lastStatus.value : this.lastStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AutomationFlow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerConfig: $triggerConfig, ')
          ..write('steps: $steps, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastExecutedAt: $lastExecutedAt, ')
          ..write('lastStatus: $lastStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, triggerType,
      triggerConfig, steps, isEnabled, createdAt, lastExecutedAt, lastStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AutomationFlow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.triggerType == this.triggerType &&
          other.triggerConfig == this.triggerConfig &&
          other.steps == this.steps &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.lastExecutedAt == this.lastExecutedAt &&
          other.lastStatus == this.lastStatus);
}

class AutomationFlowsCompanion extends UpdateCompanion<AutomationFlow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> triggerType;
  final Value<String?> triggerConfig;
  final Value<String> steps;
  final Value<int> isEnabled;
  final Value<int> createdAt;
  final Value<int?> lastExecutedAt;
  final Value<String?> lastStatus;
  final Value<int> rowid;
  const AutomationFlowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.triggerType = const Value.absent(),
    this.triggerConfig = const Value.absent(),
    this.steps = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastExecutedAt = const Value.absent(),
    this.lastStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AutomationFlowsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String triggerType,
    this.triggerConfig = const Value.absent(),
    required String steps,
    this.isEnabled = const Value.absent(),
    required int createdAt,
    this.lastExecutedAt = const Value.absent(),
    this.lastStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        triggerType = Value(triggerType),
        steps = Value(steps),
        createdAt = Value(createdAt);
  static Insertable<AutomationFlow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? triggerType,
    Expression<String>? triggerConfig,
    Expression<String>? steps,
    Expression<int>? isEnabled,
    Expression<int>? createdAt,
    Expression<int>? lastExecutedAt,
    Expression<String>? lastStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (triggerType != null) 'trigger_type': triggerType,
      if (triggerConfig != null) 'trigger_config': triggerConfig,
      if (steps != null) 'steps': steps,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (lastExecutedAt != null) 'last_executed_at': lastExecutedAt,
      if (lastStatus != null) 'last_status': lastStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AutomationFlowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? triggerType,
      Value<String?>? triggerConfig,
      Value<String>? steps,
      Value<int>? isEnabled,
      Value<int>? createdAt,
      Value<int?>? lastExecutedAt,
      Value<String?>? lastStatus,
      Value<int>? rowid}) {
    return AutomationFlowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      triggerType: triggerType ?? this.triggerType,
      triggerConfig: triggerConfig ?? this.triggerConfig,
      steps: steps ?? this.steps,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastExecutedAt: lastExecutedAt ?? this.lastExecutedAt,
      lastStatus: lastStatus ?? this.lastStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (triggerType.present) {
      map['trigger_type'] = Variable<String>(triggerType.value);
    }
    if (triggerConfig.present) {
      map['trigger_config'] = Variable<String>(triggerConfig.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<int>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastExecutedAt.present) {
      map['last_executed_at'] = Variable<int>(lastExecutedAt.value);
    }
    if (lastStatus.present) {
      map['last_status'] = Variable<String>(lastStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AutomationFlowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerConfig: $triggerConfig, ')
          ..write('steps: $steps, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastExecutedAt: $lastExecutedAt, ')
          ..write('lastStatus: $lastStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlowExecutionsTable extends FlowExecutions
    with TableInfo<$FlowExecutionsTable, FlowExecution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlowExecutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _flowIdMeta = const VerificationMeta('flowId');
  @override
  late final GeneratedColumn<String> flowId = GeneratedColumn<String>(
      'flow_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
      'started_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
      'result', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, flowId, startedAt, completedAt, status, result, error];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flow_executions';
  @override
  VerificationContext validateIntegrity(Insertable<FlowExecution> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('flow_id')) {
      context.handle(_flowIdMeta,
          flowId.isAcceptableOrUnknown(data['flow_id']!, _flowIdMeta));
    } else if (isInserting) {
      context.missing(_flowIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlowExecution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlowExecution(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      flowId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flow_id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_at']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result']),
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
    );
  }

  @override
  $FlowExecutionsTable createAlias(String alias) {
    return $FlowExecutionsTable(attachedDatabase, alias);
  }
}

class FlowExecution extends DataClass implements Insertable<FlowExecution> {
  final int id;
  final String flowId;
  final int startedAt;
  final int? completedAt;
  final String status;
  final String? result;
  final String? error;
  const FlowExecution(
      {required this.id,
      required this.flowId,
      required this.startedAt,
      this.completedAt,
      required this.status,
      this.result,
      this.error});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['flow_id'] = Variable<String>(flowId);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || result != null) {
      map['result'] = Variable<String>(result);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  FlowExecutionsCompanion toCompanion(bool nullToAbsent) {
    return FlowExecutionsCompanion(
      id: Value(id),
      flowId: Value(flowId),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      status: Value(status),
      result:
          result == null && nullToAbsent ? const Value.absent() : Value(result),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
    );
  }

  factory FlowExecution.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlowExecution(
      id: serializer.fromJson<int>(json['id']),
      flowId: serializer.fromJson<String>(json['flowId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      status: serializer.fromJson<String>(json['status']),
      result: serializer.fromJson<String?>(json['result']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'flowId': serializer.toJson<String>(flowId),
      'startedAt': serializer.toJson<int>(startedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'status': serializer.toJson<String>(status),
      'result': serializer.toJson<String?>(result),
      'error': serializer.toJson<String?>(error),
    };
  }

  FlowExecution copyWith(
          {int? id,
          String? flowId,
          int? startedAt,
          Value<int?> completedAt = const Value.absent(),
          String? status,
          Value<String?> result = const Value.absent(),
          Value<String?> error = const Value.absent()}) =>
      FlowExecution(
        id: id ?? this.id,
        flowId: flowId ?? this.flowId,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        status: status ?? this.status,
        result: result.present ? result.value : this.result,
        error: error.present ? error.value : this.error,
      );
  FlowExecution copyWithCompanion(FlowExecutionsCompanion data) {
    return FlowExecution(
      id: data.id.present ? data.id.value : this.id,
      flowId: data.flowId.present ? data.flowId.value : this.flowId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      status: data.status.present ? data.status.value : this.status,
      result: data.result.present ? data.result.value : this.result,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlowExecution(')
          ..write('id: $id, ')
          ..write('flowId: $flowId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('result: $result, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, flowId, startedAt, completedAt, status, result, error);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlowExecution &&
          other.id == this.id &&
          other.flowId == this.flowId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.status == this.status &&
          other.result == this.result &&
          other.error == this.error);
}

class FlowExecutionsCompanion extends UpdateCompanion<FlowExecution> {
  final Value<int> id;
  final Value<String> flowId;
  final Value<int> startedAt;
  final Value<int?> completedAt;
  final Value<String> status;
  final Value<String?> result;
  final Value<String?> error;
  const FlowExecutionsCompanion({
    this.id = const Value.absent(),
    this.flowId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.result = const Value.absent(),
    this.error = const Value.absent(),
  });
  FlowExecutionsCompanion.insert({
    this.id = const Value.absent(),
    required String flowId,
    required int startedAt,
    this.completedAt = const Value.absent(),
    required String status,
    this.result = const Value.absent(),
    this.error = const Value.absent(),
  })  : flowId = Value(flowId),
        startedAt = Value(startedAt),
        status = Value(status);
  static Insertable<FlowExecution> custom({
    Expression<int>? id,
    Expression<String>? flowId,
    Expression<int>? startedAt,
    Expression<int>? completedAt,
    Expression<String>? status,
    Expression<String>? result,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (flowId != null) 'flow_id': flowId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (status != null) 'status': status,
      if (result != null) 'result': result,
      if (error != null) 'error': error,
    });
  }

  FlowExecutionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? flowId,
      Value<int>? startedAt,
      Value<int?>? completedAt,
      Value<String>? status,
      Value<String?>? result,
      Value<String?>? error}) {
    return FlowExecutionsCompanion(
      id: id ?? this.id,
      flowId: flowId ?? this.flowId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (flowId.present) {
      map['flow_id'] = Variable<String>(flowId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlowExecutionsCompanion(')
          ..write('id: $id, ')
          ..write('flowId: $flowId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('result: $result, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

class $AuditLogTable extends AuditLog
    with TableInfo<$AuditLogTable, AuditLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _userQueryMeta =
      const VerificationMeta('userQuery');
  @override
  late final GeneratedColumn<String> userQuery = GeneratedColumn<String>(
      'user_query', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _llmInterpretationMeta =
      const VerificationMeta('llmInterpretation');
  @override
  late final GeneratedColumn<String> llmInterpretation =
      GeneratedColumn<String>('llm_interpretation', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionParamsMeta =
      const VerificationMeta('actionParams');
  @override
  late final GeneratedColumn<String> actionParams = GeneratedColumn<String>(
      'action_params', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _policyResultMeta =
      const VerificationMeta('policyResult');
  @override
  late final GeneratedColumn<String> policyResult = GeneratedColumn<String>(
      'policy_result', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userDecisionMeta =
      const VerificationMeta('userDecision');
  @override
  late final GeneratedColumn<String> userDecision = GeneratedColumn<String>(
      'user_decision', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionResultMeta =
      const VerificationMeta('actionResult');
  @override
  late final GeneratedColumn<String> actionResult = GeneratedColumn<String>(
      'action_result', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        timestamp,
        userQuery,
        llmInterpretation,
        actionType,
        actionParams,
        policyResult,
        userDecision,
        actionResult,
        error
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLogData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('user_query')) {
      context.handle(_userQueryMeta,
          userQuery.isAcceptableOrUnknown(data['user_query']!, _userQueryMeta));
    } else if (isInserting) {
      context.missing(_userQueryMeta);
    }
    if (data.containsKey('llm_interpretation')) {
      context.handle(
          _llmInterpretationMeta,
          llmInterpretation.isAcceptableOrUnknown(
              data['llm_interpretation']!, _llmInterpretationMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('action_params')) {
      context.handle(
          _actionParamsMeta,
          actionParams.isAcceptableOrUnknown(
              data['action_params']!, _actionParamsMeta));
    }
    if (data.containsKey('policy_result')) {
      context.handle(
          _policyResultMeta,
          policyResult.isAcceptableOrUnknown(
              data['policy_result']!, _policyResultMeta));
    } else if (isInserting) {
      context.missing(_policyResultMeta);
    }
    if (data.containsKey('user_decision')) {
      context.handle(
          _userDecisionMeta,
          userDecision.isAcceptableOrUnknown(
              data['user_decision']!, _userDecisionMeta));
    }
    if (data.containsKey('action_result')) {
      context.handle(
          _actionResultMeta,
          actionResult.isAcceptableOrUnknown(
              data['action_result']!, _actionResultMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      userQuery: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_query'])!,
      llmInterpretation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}llm_interpretation']),
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      actionParams: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_params']),
      policyResult: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}policy_result'])!,
      userDecision: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_decision']),
      actionResult: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_result']),
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
    );
  }

  @override
  $AuditLogTable createAlias(String alias) {
    return $AuditLogTable(attachedDatabase, alias);
  }
}

class AuditLogData extends DataClass implements Insertable<AuditLogData> {
  final int id;
  final int timestamp;
  final String userQuery;
  final String? llmInterpretation;
  final String actionType;
  final String? actionParams;
  final String policyResult;
  final String? userDecision;
  final String? actionResult;
  final String? error;
  const AuditLogData(
      {required this.id,
      required this.timestamp,
      required this.userQuery,
      this.llmInterpretation,
      required this.actionType,
      this.actionParams,
      required this.policyResult,
      this.userDecision,
      this.actionResult,
      this.error});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<int>(timestamp);
    map['user_query'] = Variable<String>(userQuery);
    if (!nullToAbsent || llmInterpretation != null) {
      map['llm_interpretation'] = Variable<String>(llmInterpretation);
    }
    map['action_type'] = Variable<String>(actionType);
    if (!nullToAbsent || actionParams != null) {
      map['action_params'] = Variable<String>(actionParams);
    }
    map['policy_result'] = Variable<String>(policyResult);
    if (!nullToAbsent || userDecision != null) {
      map['user_decision'] = Variable<String>(userDecision);
    }
    if (!nullToAbsent || actionResult != null) {
      map['action_result'] = Variable<String>(actionResult);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      userQuery: Value(userQuery),
      llmInterpretation: llmInterpretation == null && nullToAbsent
          ? const Value.absent()
          : Value(llmInterpretation),
      actionType: Value(actionType),
      actionParams: actionParams == null && nullToAbsent
          ? const Value.absent()
          : Value(actionParams),
      policyResult: Value(policyResult),
      userDecision: userDecision == null && nullToAbsent
          ? const Value.absent()
          : Value(userDecision),
      actionResult: actionResult == null && nullToAbsent
          ? const Value.absent()
          : Value(actionResult),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
    );
  }

  factory AuditLogData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogData(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      userQuery: serializer.fromJson<String>(json['userQuery']),
      llmInterpretation:
          serializer.fromJson<String?>(json['llmInterpretation']),
      actionType: serializer.fromJson<String>(json['actionType']),
      actionParams: serializer.fromJson<String?>(json['actionParams']),
      policyResult: serializer.fromJson<String>(json['policyResult']),
      userDecision: serializer.fromJson<String?>(json['userDecision']),
      actionResult: serializer.fromJson<String?>(json['actionResult']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<int>(timestamp),
      'userQuery': serializer.toJson<String>(userQuery),
      'llmInterpretation': serializer.toJson<String?>(llmInterpretation),
      'actionType': serializer.toJson<String>(actionType),
      'actionParams': serializer.toJson<String?>(actionParams),
      'policyResult': serializer.toJson<String>(policyResult),
      'userDecision': serializer.toJson<String?>(userDecision),
      'actionResult': serializer.toJson<String?>(actionResult),
      'error': serializer.toJson<String?>(error),
    };
  }

  AuditLogData copyWith(
          {int? id,
          int? timestamp,
          String? userQuery,
          Value<String?> llmInterpretation = const Value.absent(),
          String? actionType,
          Value<String?> actionParams = const Value.absent(),
          String? policyResult,
          Value<String?> userDecision = const Value.absent(),
          Value<String?> actionResult = const Value.absent(),
          Value<String?> error = const Value.absent()}) =>
      AuditLogData(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        userQuery: userQuery ?? this.userQuery,
        llmInterpretation: llmInterpretation.present
            ? llmInterpretation.value
            : this.llmInterpretation,
        actionType: actionType ?? this.actionType,
        actionParams:
            actionParams.present ? actionParams.value : this.actionParams,
        policyResult: policyResult ?? this.policyResult,
        userDecision:
            userDecision.present ? userDecision.value : this.userDecision,
        actionResult:
            actionResult.present ? actionResult.value : this.actionResult,
        error: error.present ? error.value : this.error,
      );
  AuditLogData copyWithCompanion(AuditLogCompanion data) {
    return AuditLogData(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      userQuery: data.userQuery.present ? data.userQuery.value : this.userQuery,
      llmInterpretation: data.llmInterpretation.present
          ? data.llmInterpretation.value
          : this.llmInterpretation,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      actionParams: data.actionParams.present
          ? data.actionParams.value
          : this.actionParams,
      policyResult: data.policyResult.present
          ? data.policyResult.value
          : this.policyResult,
      userDecision: data.userDecision.present
          ? data.userDecision.value
          : this.userDecision,
      actionResult: data.actionResult.present
          ? data.actionResult.value
          : this.actionResult,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogData(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('userQuery: $userQuery, ')
          ..write('llmInterpretation: $llmInterpretation, ')
          ..write('actionType: $actionType, ')
          ..write('actionParams: $actionParams, ')
          ..write('policyResult: $policyResult, ')
          ..write('userDecision: $userDecision, ')
          ..write('actionResult: $actionResult, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      timestamp,
      userQuery,
      llmInterpretation,
      actionType,
      actionParams,
      policyResult,
      userDecision,
      actionResult,
      error);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogData &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.userQuery == this.userQuery &&
          other.llmInterpretation == this.llmInterpretation &&
          other.actionType == this.actionType &&
          other.actionParams == this.actionParams &&
          other.policyResult == this.policyResult &&
          other.userDecision == this.userDecision &&
          other.actionResult == this.actionResult &&
          other.error == this.error);
}

class AuditLogCompanion extends UpdateCompanion<AuditLogData> {
  final Value<int> id;
  final Value<int> timestamp;
  final Value<String> userQuery;
  final Value<String?> llmInterpretation;
  final Value<String> actionType;
  final Value<String?> actionParams;
  final Value<String> policyResult;
  final Value<String?> userDecision;
  final Value<String?> actionResult;
  final Value<String?> error;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.userQuery = const Value.absent(),
    this.llmInterpretation = const Value.absent(),
    this.actionType = const Value.absent(),
    this.actionParams = const Value.absent(),
    this.policyResult = const Value.absent(),
    this.userDecision = const Value.absent(),
    this.actionResult = const Value.absent(),
    this.error = const Value.absent(),
  });
  AuditLogCompanion.insert({
    this.id = const Value.absent(),
    required int timestamp,
    required String userQuery,
    this.llmInterpretation = const Value.absent(),
    required String actionType,
    this.actionParams = const Value.absent(),
    required String policyResult,
    this.userDecision = const Value.absent(),
    this.actionResult = const Value.absent(),
    this.error = const Value.absent(),
  })  : timestamp = Value(timestamp),
        userQuery = Value(userQuery),
        actionType = Value(actionType),
        policyResult = Value(policyResult);
  static Insertable<AuditLogData> custom({
    Expression<int>? id,
    Expression<int>? timestamp,
    Expression<String>? userQuery,
    Expression<String>? llmInterpretation,
    Expression<String>? actionType,
    Expression<String>? actionParams,
    Expression<String>? policyResult,
    Expression<String>? userDecision,
    Expression<String>? actionResult,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (userQuery != null) 'user_query': userQuery,
      if (llmInterpretation != null) 'llm_interpretation': llmInterpretation,
      if (actionType != null) 'action_type': actionType,
      if (actionParams != null) 'action_params': actionParams,
      if (policyResult != null) 'policy_result': policyResult,
      if (userDecision != null) 'user_decision': userDecision,
      if (actionResult != null) 'action_result': actionResult,
      if (error != null) 'error': error,
    });
  }

  AuditLogCompanion copyWith(
      {Value<int>? id,
      Value<int>? timestamp,
      Value<String>? userQuery,
      Value<String?>? llmInterpretation,
      Value<String>? actionType,
      Value<String?>? actionParams,
      Value<String>? policyResult,
      Value<String?>? userDecision,
      Value<String?>? actionResult,
      Value<String?>? error}) {
    return AuditLogCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      userQuery: userQuery ?? this.userQuery,
      llmInterpretation: llmInterpretation ?? this.llmInterpretation,
      actionType: actionType ?? this.actionType,
      actionParams: actionParams ?? this.actionParams,
      policyResult: policyResult ?? this.policyResult,
      userDecision: userDecision ?? this.userDecision,
      actionResult: actionResult ?? this.actionResult,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (userQuery.present) {
      map['user_query'] = Variable<String>(userQuery.value);
    }
    if (llmInterpretation.present) {
      map['llm_interpretation'] = Variable<String>(llmInterpretation.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (actionParams.present) {
      map['action_params'] = Variable<String>(actionParams.value);
    }
    if (policyResult.present) {
      map['policy_result'] = Variable<String>(policyResult.value);
    }
    if (userDecision.present) {
      map['user_decision'] = Variable<String>(userDecision.value);
    }
    if (actionResult.present) {
      map['action_result'] = Variable<String>(actionResult.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('userQuery: $userQuery, ')
          ..write('llmInterpretation: $llmInterpretation, ')
          ..write('actionType: $actionType, ')
          ..write('actionParams: $actionParams, ')
          ..write('policyResult: $policyResult, ')
          ..write('userDecision: $userDecision, ')
          ..write('actionResult: $actionResult, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

class $SearchCacheTable extends SearchCache
    with TableInfo<$SearchCacheTable, SearchCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryHashMeta =
      const VerificationMeta('queryHash');
  @override
  late final GeneratedColumn<String> queryHash = GeneratedColumn<String>(
      'query_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
      'query', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resultsMeta =
      const VerificationMeta('results');
  @override
  late final GeneratedColumn<String> results = GeneratedColumn<String>(
      'results', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [queryHash, query, results, source, createdAt, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_cache';
  @override
  VerificationContext validateIntegrity(Insertable<SearchCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query_hash')) {
      context.handle(_queryHashMeta,
          queryHash.isAcceptableOrUnknown(data['query_hash']!, _queryHashMeta));
    } else if (isInserting) {
      context.missing(_queryHashMeta);
    }
    if (data.containsKey('query')) {
      context.handle(
          _queryMeta, query.isAcceptableOrUnknown(data['query']!, _queryMeta));
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('results')) {
      context.handle(_resultsMeta,
          results.isAcceptableOrUnknown(data['results']!, _resultsMeta));
    } else if (isInserting) {
      context.missing(_resultsMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {queryHash};
  @override
  SearchCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchCacheData(
      queryHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query_hash'])!,
      query: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query'])!,
      results: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}results'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expires_at'])!,
    );
  }

  @override
  $SearchCacheTable createAlias(String alias) {
    return $SearchCacheTable(attachedDatabase, alias);
  }
}

class SearchCacheData extends DataClass implements Insertable<SearchCacheData> {
  final String queryHash;
  final String query;
  final String results;
  final String source;
  final int createdAt;
  final int expiresAt;
  const SearchCacheData(
      {required this.queryHash,
      required this.query,
      required this.results,
      required this.source,
      required this.createdAt,
      required this.expiresAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query_hash'] = Variable<String>(queryHash);
    map['query'] = Variable<String>(query);
    map['results'] = Variable<String>(results);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<int>(createdAt);
    map['expires_at'] = Variable<int>(expiresAt);
    return map;
  }

  SearchCacheCompanion toCompanion(bool nullToAbsent) {
    return SearchCacheCompanion(
      queryHash: Value(queryHash),
      query: Value(query),
      results: Value(results),
      source: Value(source),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory SearchCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchCacheData(
      queryHash: serializer.fromJson<String>(json['queryHash']),
      query: serializer.fromJson<String>(json['query']),
      results: serializer.fromJson<String>(json['results']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      expiresAt: serializer.fromJson<int>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'queryHash': serializer.toJson<String>(queryHash),
      'query': serializer.toJson<String>(query),
      'results': serializer.toJson<String>(results),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<int>(createdAt),
      'expiresAt': serializer.toJson<int>(expiresAt),
    };
  }

  SearchCacheData copyWith(
          {String? queryHash,
          String? query,
          String? results,
          String? source,
          int? createdAt,
          int? expiresAt}) =>
      SearchCacheData(
        queryHash: queryHash ?? this.queryHash,
        query: query ?? this.query,
        results: results ?? this.results,
        source: source ?? this.source,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
      );
  SearchCacheData copyWithCompanion(SearchCacheCompanion data) {
    return SearchCacheData(
      queryHash: data.queryHash.present ? data.queryHash.value : this.queryHash,
      query: data.query.present ? data.query.value : this.query,
      results: data.results.present ? data.results.value : this.results,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchCacheData(')
          ..write('queryHash: $queryHash, ')
          ..write('query: $query, ')
          ..write('results: $results, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(queryHash, query, results, source, createdAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchCacheData &&
          other.queryHash == this.queryHash &&
          other.query == this.query &&
          other.results == this.results &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class SearchCacheCompanion extends UpdateCompanion<SearchCacheData> {
  final Value<String> queryHash;
  final Value<String> query;
  final Value<String> results;
  final Value<String> source;
  final Value<int> createdAt;
  final Value<int> expiresAt;
  final Value<int> rowid;
  const SearchCacheCompanion({
    this.queryHash = const Value.absent(),
    this.query = const Value.absent(),
    this.results = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchCacheCompanion.insert({
    required String queryHash,
    required String query,
    required String results,
    required String source,
    required int createdAt,
    required int expiresAt,
    this.rowid = const Value.absent(),
  })  : queryHash = Value(queryHash),
        query = Value(query),
        results = Value(results),
        source = Value(source),
        createdAt = Value(createdAt),
        expiresAt = Value(expiresAt);
  static Insertable<SearchCacheData> custom({
    Expression<String>? queryHash,
    Expression<String>? query,
    Expression<String>? results,
    Expression<String>? source,
    Expression<int>? createdAt,
    Expression<int>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (queryHash != null) 'query_hash': queryHash,
      if (query != null) 'query': query,
      if (results != null) 'results': results,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchCacheCompanion copyWith(
      {Value<String>? queryHash,
      Value<String>? query,
      Value<String>? results,
      Value<String>? source,
      Value<int>? createdAt,
      Value<int>? expiresAt,
      Value<int>? rowid}) {
    return SearchCacheCompanion(
      queryHash: queryHash ?? this.queryHash,
      query: query ?? this.query,
      results: results ?? this.results,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (queryHash.present) {
      map['query_hash'] = Variable<String>(queryHash.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (results.present) {
      map['results'] = Variable<String>(results.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchCacheCompanion(')
          ..write('queryHash: $queryHash, ')
          ..write('query: $query, ')
          ..write('results: $results, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizzesTable extends Quizzes with TableInfo<$QuizzesTable, Quizze> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizzesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourcePdfPathMeta =
      const VerificationMeta('sourcePdfPath');
  @override
  late final GeneratedColumn<String> sourcePdfPath = GeneratedColumn<String>(
      'source_pdf_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionsMeta =
      const VerificationMeta('questions');
  @override
  late final GeneratedColumn<String> questions = GeneratedColumn<String>(
      'questions', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _totalQuestionsMeta =
      const VerificationMeta('totalQuestions');
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
      'total_questions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sourcePdfPath,
        title,
        questions,
        score,
        totalQuestions,
        completedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quizzes';
  @override
  VerificationContext validateIntegrity(Insertable<Quizze> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_pdf_path')) {
      context.handle(
          _sourcePdfPathMeta,
          sourcePdfPath.isAcceptableOrUnknown(
              data['source_pdf_path']!, _sourcePdfPathMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('questions')) {
      context.handle(_questionsMeta,
          questions.isAcceptableOrUnknown(data['questions']!, _questionsMeta));
    } else if (isInserting) {
      context.missing(_questionsMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    if (data.containsKey('total_questions')) {
      context.handle(
          _totalQuestionsMeta,
          totalQuestions.isAcceptableOrUnknown(
              data['total_questions']!, _totalQuestionsMeta));
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Quizze map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Quizze(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourcePdfPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_pdf_path']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      questions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}questions'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score']),
      totalQuestions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_questions'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $QuizzesTable createAlias(String alias) {
    return $QuizzesTable(attachedDatabase, alias);
  }
}

class Quizze extends DataClass implements Insertable<Quizze> {
  final String id;
  final String? sourcePdfPath;
  final String title;
  final String questions;
  final int? score;
  final int totalQuestions;
  final int? completedAt;
  final int createdAt;
  const Quizze(
      {required this.id,
      this.sourcePdfPath,
      required this.title,
      required this.questions,
      this.score,
      required this.totalQuestions,
      this.completedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sourcePdfPath != null) {
      map['source_pdf_path'] = Variable<String>(sourcePdfPath);
    }
    map['title'] = Variable<String>(title);
    map['questions'] = Variable<String>(questions);
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    map['total_questions'] = Variable<int>(totalQuestions);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  QuizzesCompanion toCompanion(bool nullToAbsent) {
    return QuizzesCompanion(
      id: Value(id),
      sourcePdfPath: sourcePdfPath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePdfPath),
      title: Value(title),
      questions: Value(questions),
      score:
          score == null && nullToAbsent ? const Value.absent() : Value(score),
      totalQuestions: Value(totalQuestions),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Quizze.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Quizze(
      id: serializer.fromJson<String>(json['id']),
      sourcePdfPath: serializer.fromJson<String?>(json['sourcePdfPath']),
      title: serializer.fromJson<String>(json['title']),
      questions: serializer.fromJson<String>(json['questions']),
      score: serializer.fromJson<int?>(json['score']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourcePdfPath': serializer.toJson<String?>(sourcePdfPath),
      'title': serializer.toJson<String>(title),
      'questions': serializer.toJson<String>(questions),
      'score': serializer.toJson<int?>(score),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'completedAt': serializer.toJson<int?>(completedAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Quizze copyWith(
          {String? id,
          Value<String?> sourcePdfPath = const Value.absent(),
          String? title,
          String? questions,
          Value<int?> score = const Value.absent(),
          int? totalQuestions,
          Value<int?> completedAt = const Value.absent(),
          int? createdAt}) =>
      Quizze(
        id: id ?? this.id,
        sourcePdfPath:
            sourcePdfPath.present ? sourcePdfPath.value : this.sourcePdfPath,
        title: title ?? this.title,
        questions: questions ?? this.questions,
        score: score.present ? score.value : this.score,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  Quizze copyWithCompanion(QuizzesCompanion data) {
    return Quizze(
      id: data.id.present ? data.id.value : this.id,
      sourcePdfPath: data.sourcePdfPath.present
          ? data.sourcePdfPath.value
          : this.sourcePdfPath,
      title: data.title.present ? data.title.value : this.title,
      questions: data.questions.present ? data.questions.value : this.questions,
      score: data.score.present ? data.score.value : this.score,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quizze(')
          ..write('id: $id, ')
          ..write('sourcePdfPath: $sourcePdfPath, ')
          ..write('title: $title, ')
          ..write('questions: $questions, ')
          ..write('score: $score, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourcePdfPath, title, questions, score,
      totalQuestions, completedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quizze &&
          other.id == this.id &&
          other.sourcePdfPath == this.sourcePdfPath &&
          other.title == this.title &&
          other.questions == this.questions &&
          other.score == this.score &&
          other.totalQuestions == this.totalQuestions &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt);
}

class QuizzesCompanion extends UpdateCompanion<Quizze> {
  final Value<String> id;
  final Value<String?> sourcePdfPath;
  final Value<String> title;
  final Value<String> questions;
  final Value<int?> score;
  final Value<int> totalQuestions;
  final Value<int?> completedAt;
  final Value<int> createdAt;
  final Value<int> rowid;
  const QuizzesCompanion({
    this.id = const Value.absent(),
    this.sourcePdfPath = const Value.absent(),
    this.title = const Value.absent(),
    this.questions = const Value.absent(),
    this.score = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizzesCompanion.insert({
    required String id,
    this.sourcePdfPath = const Value.absent(),
    required String title,
    required String questions,
    this.score = const Value.absent(),
    required int totalQuestions,
    this.completedAt = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        questions = Value(questions),
        totalQuestions = Value(totalQuestions),
        createdAt = Value(createdAt);
  static Insertable<Quizze> custom({
    Expression<String>? id,
    Expression<String>? sourcePdfPath,
    Expression<String>? title,
    Expression<String>? questions,
    Expression<int>? score,
    Expression<int>? totalQuestions,
    Expression<int>? completedAt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourcePdfPath != null) 'source_pdf_path': sourcePdfPath,
      if (title != null) 'title': title,
      if (questions != null) 'questions': questions,
      if (score != null) 'score': score,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizzesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? sourcePdfPath,
      Value<String>? title,
      Value<String>? questions,
      Value<int?>? score,
      Value<int>? totalQuestions,
      Value<int?>? completedAt,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return QuizzesCompanion(
      id: id ?? this.id,
      sourcePdfPath: sourcePdfPath ?? this.sourcePdfPath,
      title: title ?? this.title,
      questions: questions ?? this.questions,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourcePdfPath.present) {
      map['source_pdf_path'] = Variable<String>(sourcePdfPath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (questions.present) {
      map['questions'] = Variable<String>(questions.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizzesCompanion(')
          ..write('id: $id, ')
          ..write('sourcePdfPath: $sourcePdfPath, ')
          ..write('title: $title, ')
          ..write('questions: $questions, ')
          ..write('score: $score, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatsTable chats = $ChatsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $DownloadedModelsTable downloadedModels =
      $DownloadedModelsTable(this);
  late final $UsageLogsTable usageLogs = $UsageLogsTable(this);
  late final $ModelCacheTable modelCache = $ModelCacheTable(this);
  late final $AutomationFlowsTable automationFlows =
      $AutomationFlowsTable(this);
  late final $FlowExecutionsTable flowExecutions = $FlowExecutionsTable(this);
  late final $AuditLogTable auditLog = $AuditLogTable(this);
  late final $SearchCacheTable searchCache = $SearchCacheTable(this);
  late final $QuizzesTable quizzes = $QuizzesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        chats,
        messages,
        downloadedModels,
        usageLogs,
        modelCache,
        automationFlows,
        flowExecutions,
        auditLog,
        searchCache,
        quizzes
      ];
}

typedef $$ChatsTableCreateCompanionBuilder = ChatsCompanion Function({
  required String id,
  Value<String?> title,
  required int createdAt,
  Value<int> messageCount,
  Value<String?> systemPrompt,
  Value<String?> modelId,
  Value<int> isPinned,
  Value<int> rowid,
});
typedef $$ChatsTableUpdateCompanionBuilder = ChatsCompanion Function({
  Value<String> id,
  Value<String?> title,
  Value<int> createdAt,
  Value<int> messageCount,
  Value<String?> systemPrompt,
  Value<String?> modelId,
  Value<int> isPinned,
  Value<int> rowid,
});

final class $$ChatsTableReferences
    extends BaseReferences<_$AppDatabase, $ChatsTable, Chat> {
  $$ChatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.messages,
          aliasName: $_aliasNameGenerator(db.chats.id, db.messages.chatId));

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager($_db, $_db.messages)
        .filter((f) => f.chatId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ChatsTableFilterComposer extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get messageCount => $composableBuilder(
      column: $table.messageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  Expression<bool> messagesRefs(
      Expression<bool> Function($$MessagesTableFilterComposer f) f) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.messages,
        getReferencedColumn: (t) => t.chatId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessagesTableFilterComposer(
              $db: $db,
              $table: $db.messages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get messageCount => $composableBuilder(
      column: $table.messageCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));
}

class $$ChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get messageCount => $composableBuilder(
      column: $table.messageCount, builder: (column) => column);

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<int> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  Expression<T> messagesRefs<T extends Object>(
      Expression<T> Function($$MessagesTableAnnotationComposer a) f) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.messages,
        getReferencedColumn: (t) => t.chatId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessagesTableAnnotationComposer(
              $db: $db,
              $table: $db.messages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatsTable,
    Chat,
    $$ChatsTableFilterComposer,
    $$ChatsTableOrderingComposer,
    $$ChatsTableAnnotationComposer,
    $$ChatsTableCreateCompanionBuilder,
    $$ChatsTableUpdateCompanionBuilder,
    (Chat, $$ChatsTableReferences),
    Chat,
    PrefetchHooks Function({bool messagesRefs})> {
  $$ChatsTableTableManager(_$AppDatabase db, $ChatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> messageCount = const Value.absent(),
            Value<String?> systemPrompt = const Value.absent(),
            Value<String?> modelId = const Value.absent(),
            Value<int> isPinned = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatsCompanion(
            id: id,
            title: title,
            createdAt: createdAt,
            messageCount: messageCount,
            systemPrompt: systemPrompt,
            modelId: modelId,
            isPinned: isPinned,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> title = const Value.absent(),
            required int createdAt,
            Value<int> messageCount = const Value.absent(),
            Value<String?> systemPrompt = const Value.absent(),
            Value<String?> modelId = const Value.absent(),
            Value<int> isPinned = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatsCompanion.insert(
            id: id,
            title: title,
            createdAt: createdAt,
            messageCount: messageCount,
            systemPrompt: systemPrompt,
            modelId: modelId,
            isPinned: isPinned,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ChatsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({messagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (messagesRefs) db.messages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messagesRefs)
                    await $_getPrefetchedData<Chat, $ChatsTable, Message>(
                        currentTable: table,
                        referencedTable:
                            $$ChatsTableReferences._messagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChatsTableReferences(db, table, p0).messagesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.chatId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ChatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatsTable,
    Chat,
    $$ChatsTableFilterComposer,
    $$ChatsTableOrderingComposer,
    $$ChatsTableAnnotationComposer,
    $$ChatsTableCreateCompanionBuilder,
    $$ChatsTableUpdateCompanionBuilder,
    (Chat, $$ChatsTableReferences),
    Chat,
    PrefetchHooks Function({bool messagesRefs})>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  required String chatId,
  required String content,
  required int isUser,
  required int createdAt,
  Value<String?> imagePath,
  Value<String?> modelId,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  Value<String> chatId,
  Value<String> content,
  Value<int> isUser,
  Value<int> createdAt,
  Value<String?> imagePath,
  Value<String?> modelId,
});

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatsTable _chatIdTable(_$AppDatabase db) => db.chats
      .createAlias($_aliasNameGenerator(db.messages.chatId, db.chats.id));

  $$ChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<String>('chat_id')!;

    final manager = $$ChatsTableTableManager($_db, $_db.chats)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isUser => $composableBuilder(
      column: $table.isUser, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnFilters(column));

  $$ChatsTableFilterComposer get chatId {
    final $$ChatsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chatId,
        referencedTable: $db.chats,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChatsTableFilterComposer(
              $db: $db,
              $table: $db.chats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isUser => $composableBuilder(
      column: $table.isUser, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnOrderings(column));

  $$ChatsTableOrderingComposer get chatId {
    final $$ChatsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chatId,
        referencedTable: $db.chats,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChatsTableOrderingComposer(
              $db: $db,
              $table: $db.chats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get isUser =>
      $composableBuilder(column: $table.isUser, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  $$ChatsTableAnnotationComposer get chatId {
    final $$ChatsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chatId,
        referencedTable: $db.chats,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChatsTableAnnotationComposer(
              $db: $db,
              $table: $db.chats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, $$MessagesTableReferences),
    Message,
    PrefetchHooks Function({bool chatId})> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> chatId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> isUser = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> modelId = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            chatId: chatId,
            content: content,
            isUser: isUser,
            createdAt: createdAt,
            imagePath: imagePath,
            modelId: modelId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String chatId,
            required String content,
            required int isUser,
            required int createdAt,
            Value<String?> imagePath = const Value.absent(),
            Value<String?> modelId = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            chatId: chatId,
            content: content,
            isUser: isUser,
            createdAt: createdAt,
            imagePath: imagePath,
            modelId: modelId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MessagesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({chatId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chatId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chatId,
                    referencedTable: $$MessagesTableReferences._chatIdTable(db),
                    referencedColumn:
                        $$MessagesTableReferences._chatIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, $$MessagesTableReferences),
    Message,
    PrefetchHooks Function({bool chatId})>;
typedef $$DownloadedModelsTableCreateCompanionBuilder
    = DownloadedModelsCompanion Function({
  required String id,
  required String name,
  required int sizeMb,
  required String quant,
  required String localPath,
  required String templateType,
  Value<String?> description,
  Value<String?> bestFor,
  Value<int> isCustom,
  required int discoveredAt,
  Value<int> fileSizeBytes,
  Value<String?> fileHash,
  Value<int?> lastVerified,
  Value<int> rowid,
});
typedef $$DownloadedModelsTableUpdateCompanionBuilder
    = DownloadedModelsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> sizeMb,
  Value<String> quant,
  Value<String> localPath,
  Value<String> templateType,
  Value<String?> description,
  Value<String?> bestFor,
  Value<int> isCustom,
  Value<int> discoveredAt,
  Value<int> fileSizeBytes,
  Value<String?> fileHash,
  Value<int?> lastVerified,
  Value<int> rowid,
});

class $$DownloadedModelsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadedModelsTable> {
  $$DownloadedModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeMb => $composableBuilder(
      column: $table.sizeMb, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quant => $composableBuilder(
      column: $table.quant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateType => $composableBuilder(
      column: $table.templateType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bestFor => $composableBuilder(
      column: $table.bestFor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discoveredAt => $composableBuilder(
      column: $table.discoveredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileHash => $composableBuilder(
      column: $table.fileHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastVerified => $composableBuilder(
      column: $table.lastVerified, builder: (column) => ColumnFilters(column));
}

class $$DownloadedModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadedModelsTable> {
  $$DownloadedModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeMb => $composableBuilder(
      column: $table.sizeMb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quant => $composableBuilder(
      column: $table.quant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateType => $composableBuilder(
      column: $table.templateType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bestFor => $composableBuilder(
      column: $table.bestFor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discoveredAt => $composableBuilder(
      column: $table.discoveredAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileHash => $composableBuilder(
      column: $table.fileHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastVerified => $composableBuilder(
      column: $table.lastVerified,
      builder: (column) => ColumnOrderings(column));
}

class $$DownloadedModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadedModelsTable> {
  $$DownloadedModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sizeMb =>
      $composableBuilder(column: $table.sizeMb, builder: (column) => column);

  GeneratedColumn<String> get quant =>
      $composableBuilder(column: $table.quant, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get templateType => $composableBuilder(
      column: $table.templateType, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get bestFor =>
      $composableBuilder(column: $table.bestFor, builder: (column) => column);

  GeneratedColumn<int> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<int> get discoveredAt => $composableBuilder(
      column: $table.discoveredAt, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<String> get fileHash =>
      $composableBuilder(column: $table.fileHash, builder: (column) => column);

  GeneratedColumn<int> get lastVerified => $composableBuilder(
      column: $table.lastVerified, builder: (column) => column);
}

class $$DownloadedModelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadedModelsTable,
    DownloadedModel,
    $$DownloadedModelsTableFilterComposer,
    $$DownloadedModelsTableOrderingComposer,
    $$DownloadedModelsTableAnnotationComposer,
    $$DownloadedModelsTableCreateCompanionBuilder,
    $$DownloadedModelsTableUpdateCompanionBuilder,
    (
      DownloadedModel,
      BaseReferences<_$AppDatabase, $DownloadedModelsTable, DownloadedModel>
    ),
    DownloadedModel,
    PrefetchHooks Function()> {
  $$DownloadedModelsTableTableManager(
      _$AppDatabase db, $DownloadedModelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadedModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadedModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sizeMb = const Value.absent(),
            Value<String> quant = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String> templateType = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> bestFor = const Value.absent(),
            Value<int> isCustom = const Value.absent(),
            Value<int> discoveredAt = const Value.absent(),
            Value<int> fileSizeBytes = const Value.absent(),
            Value<String?> fileHash = const Value.absent(),
            Value<int?> lastVerified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadedModelsCompanion(
            id: id,
            name: name,
            sizeMb: sizeMb,
            quant: quant,
            localPath: localPath,
            templateType: templateType,
            description: description,
            bestFor: bestFor,
            isCustom: isCustom,
            discoveredAt: discoveredAt,
            fileSizeBytes: fileSizeBytes,
            fileHash: fileHash,
            lastVerified: lastVerified,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int sizeMb,
            required String quant,
            required String localPath,
            required String templateType,
            Value<String?> description = const Value.absent(),
            Value<String?> bestFor = const Value.absent(),
            Value<int> isCustom = const Value.absent(),
            required int discoveredAt,
            Value<int> fileSizeBytes = const Value.absent(),
            Value<String?> fileHash = const Value.absent(),
            Value<int?> lastVerified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadedModelsCompanion.insert(
            id: id,
            name: name,
            sizeMb: sizeMb,
            quant: quant,
            localPath: localPath,
            templateType: templateType,
            description: description,
            bestFor: bestFor,
            isCustom: isCustom,
            discoveredAt: discoveredAt,
            fileSizeBytes: fileSizeBytes,
            fileHash: fileHash,
            lastVerified: lastVerified,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DownloadedModelsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadedModelsTable,
    DownloadedModel,
    $$DownloadedModelsTableFilterComposer,
    $$DownloadedModelsTableOrderingComposer,
    $$DownloadedModelsTableAnnotationComposer,
    $$DownloadedModelsTableCreateCompanionBuilder,
    $$DownloadedModelsTableUpdateCompanionBuilder,
    (
      DownloadedModel,
      BaseReferences<_$AppDatabase, $DownloadedModelsTable, DownloadedModel>
    ),
    DownloadedModel,
    PrefetchHooks Function()>;
typedef $$UsageLogsTableCreateCompanionBuilder = UsageLogsCompanion Function({
  Value<int> id,
  required int timestamp,
  Value<String> type,
});
typedef $$UsageLogsTableUpdateCompanionBuilder = UsageLogsCompanion Function({
  Value<int> id,
  Value<int> timestamp,
  Value<String> type,
});

class $$UsageLogsTableFilterComposer
    extends Composer<_$AppDatabase, $UsageLogsTable> {
  $$UsageLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));
}

class $$UsageLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsageLogsTable> {
  $$UsageLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));
}

class $$UsageLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsageLogsTable> {
  $$UsageLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$UsageLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsageLogsTable,
    UsageLog,
    $$UsageLogsTableFilterComposer,
    $$UsageLogsTableOrderingComposer,
    $$UsageLogsTableAnnotationComposer,
    $$UsageLogsTableCreateCompanionBuilder,
    $$UsageLogsTableUpdateCompanionBuilder,
    (UsageLog, BaseReferences<_$AppDatabase, $UsageLogsTable, UsageLog>),
    UsageLog,
    PrefetchHooks Function()> {
  $$UsageLogsTableTableManager(_$AppDatabase db, $UsageLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsageLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsageLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsageLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<String> type = const Value.absent(),
          }) =>
              UsageLogsCompanion(
            id: id,
            timestamp: timestamp,
            type: type,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int timestamp,
            Value<String> type = const Value.absent(),
          }) =>
              UsageLogsCompanion.insert(
            id: id,
            timestamp: timestamp,
            type: type,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsageLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsageLogsTable,
    UsageLog,
    $$UsageLogsTableFilterComposer,
    $$UsageLogsTableOrderingComposer,
    $$UsageLogsTableAnnotationComposer,
    $$UsageLogsTableCreateCompanionBuilder,
    $$UsageLogsTableUpdateCompanionBuilder,
    (UsageLog, BaseReferences<_$AppDatabase, $UsageLogsTable, UsageLog>),
    UsageLog,
    PrefetchHooks Function()>;
typedef $$ModelCacheTableCreateCompanionBuilder = ModelCacheCompanion Function({
  required String filePath,
  Value<String?> fileHash,
  required int lastModified,
  required int discoveredAt,
  Value<int> rowid,
});
typedef $$ModelCacheTableUpdateCompanionBuilder = ModelCacheCompanion Function({
  Value<String> filePath,
  Value<String?> fileHash,
  Value<int> lastModified,
  Value<int> discoveredAt,
  Value<int> rowid,
});

class $$ModelCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ModelCacheTable> {
  $$ModelCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileHash => $composableBuilder(
      column: $table.fileHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discoveredAt => $composableBuilder(
      column: $table.discoveredAt, builder: (column) => ColumnFilters(column));
}

class $$ModelCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ModelCacheTable> {
  $$ModelCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileHash => $composableBuilder(
      column: $table.fileHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discoveredAt => $composableBuilder(
      column: $table.discoveredAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ModelCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModelCacheTable> {
  $$ModelCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fileHash =>
      $composableBuilder(column: $table.fileHash, builder: (column) => column);

  GeneratedColumn<int> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);

  GeneratedColumn<int> get discoveredAt => $composableBuilder(
      column: $table.discoveredAt, builder: (column) => column);
}

class $$ModelCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ModelCacheTable,
    ModelCacheData,
    $$ModelCacheTableFilterComposer,
    $$ModelCacheTableOrderingComposer,
    $$ModelCacheTableAnnotationComposer,
    $$ModelCacheTableCreateCompanionBuilder,
    $$ModelCacheTableUpdateCompanionBuilder,
    (
      ModelCacheData,
      BaseReferences<_$AppDatabase, $ModelCacheTable, ModelCacheData>
    ),
    ModelCacheData,
    PrefetchHooks Function()> {
  $$ModelCacheTableTableManager(_$AppDatabase db, $ModelCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> filePath = const Value.absent(),
            Value<String?> fileHash = const Value.absent(),
            Value<int> lastModified = const Value.absent(),
            Value<int> discoveredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ModelCacheCompanion(
            filePath: filePath,
            fileHash: fileHash,
            lastModified: lastModified,
            discoveredAt: discoveredAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String filePath,
            Value<String?> fileHash = const Value.absent(),
            required int lastModified,
            required int discoveredAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ModelCacheCompanion.insert(
            filePath: filePath,
            fileHash: fileHash,
            lastModified: lastModified,
            discoveredAt: discoveredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ModelCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ModelCacheTable,
    ModelCacheData,
    $$ModelCacheTableFilterComposer,
    $$ModelCacheTableOrderingComposer,
    $$ModelCacheTableAnnotationComposer,
    $$ModelCacheTableCreateCompanionBuilder,
    $$ModelCacheTableUpdateCompanionBuilder,
    (
      ModelCacheData,
      BaseReferences<_$AppDatabase, $ModelCacheTable, ModelCacheData>
    ),
    ModelCacheData,
    PrefetchHooks Function()>;
typedef $$AutomationFlowsTableCreateCompanionBuilder = AutomationFlowsCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  required String triggerType,
  Value<String?> triggerConfig,
  required String steps,
  Value<int> isEnabled,
  required int createdAt,
  Value<int?> lastExecutedAt,
  Value<String?> lastStatus,
  Value<int> rowid,
});
typedef $$AutomationFlowsTableUpdateCompanionBuilder = AutomationFlowsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> triggerType,
  Value<String?> triggerConfig,
  Value<String> steps,
  Value<int> isEnabled,
  Value<int> createdAt,
  Value<int?> lastExecutedAt,
  Value<String?> lastStatus,
  Value<int> rowid,
});

class $$AutomationFlowsTableFilterComposer
    extends Composer<_$AppDatabase, $AutomationFlowsTable> {
  $$AutomationFlowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triggerConfig => $composableBuilder(
      column: $table.triggerConfig, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastExecutedAt => $composableBuilder(
      column: $table.lastExecutedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastStatus => $composableBuilder(
      column: $table.lastStatus, builder: (column) => ColumnFilters(column));
}

class $$AutomationFlowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AutomationFlowsTable> {
  $$AutomationFlowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggerConfig => $composableBuilder(
      column: $table.triggerConfig,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastExecutedAt => $composableBuilder(
      column: $table.lastExecutedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastStatus => $composableBuilder(
      column: $table.lastStatus, builder: (column) => ColumnOrderings(column));
}

class $$AutomationFlowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AutomationFlowsTable> {
  $$AutomationFlowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => column);

  GeneratedColumn<String> get triggerConfig => $composableBuilder(
      column: $table.triggerConfig, builder: (column) => column);

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<int> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastExecutedAt => $composableBuilder(
      column: $table.lastExecutedAt, builder: (column) => column);

  GeneratedColumn<String> get lastStatus => $composableBuilder(
      column: $table.lastStatus, builder: (column) => column);
}

class $$AutomationFlowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AutomationFlowsTable,
    AutomationFlow,
    $$AutomationFlowsTableFilterComposer,
    $$AutomationFlowsTableOrderingComposer,
    $$AutomationFlowsTableAnnotationComposer,
    $$AutomationFlowsTableCreateCompanionBuilder,
    $$AutomationFlowsTableUpdateCompanionBuilder,
    (
      AutomationFlow,
      BaseReferences<_$AppDatabase, $AutomationFlowsTable, AutomationFlow>
    ),
    AutomationFlow,
    PrefetchHooks Function()> {
  $$AutomationFlowsTableTableManager(
      _$AppDatabase db, $AutomationFlowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AutomationFlowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AutomationFlowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AutomationFlowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> triggerType = const Value.absent(),
            Value<String?> triggerConfig = const Value.absent(),
            Value<String> steps = const Value.absent(),
            Value<int> isEnabled = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> lastExecutedAt = const Value.absent(),
            Value<String?> lastStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AutomationFlowsCompanion(
            id: id,
            name: name,
            description: description,
            triggerType: triggerType,
            triggerConfig: triggerConfig,
            steps: steps,
            isEnabled: isEnabled,
            createdAt: createdAt,
            lastExecutedAt: lastExecutedAt,
            lastStatus: lastStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String triggerType,
            Value<String?> triggerConfig = const Value.absent(),
            required String steps,
            Value<int> isEnabled = const Value.absent(),
            required int createdAt,
            Value<int?> lastExecutedAt = const Value.absent(),
            Value<String?> lastStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AutomationFlowsCompanion.insert(
            id: id,
            name: name,
            description: description,
            triggerType: triggerType,
            triggerConfig: triggerConfig,
            steps: steps,
            isEnabled: isEnabled,
            createdAt: createdAt,
            lastExecutedAt: lastExecutedAt,
            lastStatus: lastStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AutomationFlowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AutomationFlowsTable,
    AutomationFlow,
    $$AutomationFlowsTableFilterComposer,
    $$AutomationFlowsTableOrderingComposer,
    $$AutomationFlowsTableAnnotationComposer,
    $$AutomationFlowsTableCreateCompanionBuilder,
    $$AutomationFlowsTableUpdateCompanionBuilder,
    (
      AutomationFlow,
      BaseReferences<_$AppDatabase, $AutomationFlowsTable, AutomationFlow>
    ),
    AutomationFlow,
    PrefetchHooks Function()>;
typedef $$FlowExecutionsTableCreateCompanionBuilder = FlowExecutionsCompanion
    Function({
  Value<int> id,
  required String flowId,
  required int startedAt,
  Value<int?> completedAt,
  required String status,
  Value<String?> result,
  Value<String?> error,
});
typedef $$FlowExecutionsTableUpdateCompanionBuilder = FlowExecutionsCompanion
    Function({
  Value<int> id,
  Value<String> flowId,
  Value<int> startedAt,
  Value<int?> completedAt,
  Value<String> status,
  Value<String?> result,
  Value<String?> error,
});

class $$FlowExecutionsTableFilterComposer
    extends Composer<_$AppDatabase, $FlowExecutionsTable> {
  $$FlowExecutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flowId => $composableBuilder(
      column: $table.flowId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));
}

class $$FlowExecutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlowExecutionsTable> {
  $$FlowExecutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flowId => $composableBuilder(
      column: $table.flowId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));
}

class $$FlowExecutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlowExecutionsTable> {
  $$FlowExecutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get flowId =>
      $composableBuilder(column: $table.flowId, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$FlowExecutionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FlowExecutionsTable,
    FlowExecution,
    $$FlowExecutionsTableFilterComposer,
    $$FlowExecutionsTableOrderingComposer,
    $$FlowExecutionsTableAnnotationComposer,
    $$FlowExecutionsTableCreateCompanionBuilder,
    $$FlowExecutionsTableUpdateCompanionBuilder,
    (
      FlowExecution,
      BaseReferences<_$AppDatabase, $FlowExecutionsTable, FlowExecution>
    ),
    FlowExecution,
    PrefetchHooks Function()> {
  $$FlowExecutionsTableTableManager(
      _$AppDatabase db, $FlowExecutionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlowExecutionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlowExecutionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlowExecutionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> flowId = const Value.absent(),
            Value<int> startedAt = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> result = const Value.absent(),
            Value<String?> error = const Value.absent(),
          }) =>
              FlowExecutionsCompanion(
            id: id,
            flowId: flowId,
            startedAt: startedAt,
            completedAt: completedAt,
            status: status,
            result: result,
            error: error,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String flowId,
            required int startedAt,
            Value<int?> completedAt = const Value.absent(),
            required String status,
            Value<String?> result = const Value.absent(),
            Value<String?> error = const Value.absent(),
          }) =>
              FlowExecutionsCompanion.insert(
            id: id,
            flowId: flowId,
            startedAt: startedAt,
            completedAt: completedAt,
            status: status,
            result: result,
            error: error,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FlowExecutionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FlowExecutionsTable,
    FlowExecution,
    $$FlowExecutionsTableFilterComposer,
    $$FlowExecutionsTableOrderingComposer,
    $$FlowExecutionsTableAnnotationComposer,
    $$FlowExecutionsTableCreateCompanionBuilder,
    $$FlowExecutionsTableUpdateCompanionBuilder,
    (
      FlowExecution,
      BaseReferences<_$AppDatabase, $FlowExecutionsTable, FlowExecution>
    ),
    FlowExecution,
    PrefetchHooks Function()>;
typedef $$AuditLogTableCreateCompanionBuilder = AuditLogCompanion Function({
  Value<int> id,
  required int timestamp,
  required String userQuery,
  Value<String?> llmInterpretation,
  required String actionType,
  Value<String?> actionParams,
  required String policyResult,
  Value<String?> userDecision,
  Value<String?> actionResult,
  Value<String?> error,
});
typedef $$AuditLogTableUpdateCompanionBuilder = AuditLogCompanion Function({
  Value<int> id,
  Value<int> timestamp,
  Value<String> userQuery,
  Value<String?> llmInterpretation,
  Value<String> actionType,
  Value<String?> actionParams,
  Value<String> policyResult,
  Value<String?> userDecision,
  Value<String?> actionResult,
  Value<String?> error,
});

class $$AuditLogTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userQuery => $composableBuilder(
      column: $table.userQuery, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get llmInterpretation => $composableBuilder(
      column: $table.llmInterpretation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionParams => $composableBuilder(
      column: $table.actionParams, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get policyResult => $composableBuilder(
      column: $table.policyResult, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userDecision => $composableBuilder(
      column: $table.userDecision, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionResult => $composableBuilder(
      column: $table.actionResult, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));
}

class $$AuditLogTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userQuery => $composableBuilder(
      column: $table.userQuery, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get llmInterpretation => $composableBuilder(
      column: $table.llmInterpretation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionParams => $composableBuilder(
      column: $table.actionParams,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get policyResult => $composableBuilder(
      column: $table.policyResult,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userDecision => $composableBuilder(
      column: $table.userDecision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionResult => $composableBuilder(
      column: $table.actionResult,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));
}

class $$AuditLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get userQuery =>
      $composableBuilder(column: $table.userQuery, builder: (column) => column);

  GeneratedColumn<String> get llmInterpretation => $composableBuilder(
      column: $table.llmInterpretation, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => column);

  GeneratedColumn<String> get actionParams => $composableBuilder(
      column: $table.actionParams, builder: (column) => column);

  GeneratedColumn<String> get policyResult => $composableBuilder(
      column: $table.policyResult, builder: (column) => column);

  GeneratedColumn<String> get userDecision => $composableBuilder(
      column: $table.userDecision, builder: (column) => column);

  GeneratedColumn<String> get actionResult => $composableBuilder(
      column: $table.actionResult, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$AuditLogTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditLogTable,
    AuditLogData,
    $$AuditLogTableFilterComposer,
    $$AuditLogTableOrderingComposer,
    $$AuditLogTableAnnotationComposer,
    $$AuditLogTableCreateCompanionBuilder,
    $$AuditLogTableUpdateCompanionBuilder,
    (AuditLogData, BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData>),
    AuditLogData,
    PrefetchHooks Function()> {
  $$AuditLogTableTableManager(_$AppDatabase db, $AuditLogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<String> userQuery = const Value.absent(),
            Value<String?> llmInterpretation = const Value.absent(),
            Value<String> actionType = const Value.absent(),
            Value<String?> actionParams = const Value.absent(),
            Value<String> policyResult = const Value.absent(),
            Value<String?> userDecision = const Value.absent(),
            Value<String?> actionResult = const Value.absent(),
            Value<String?> error = const Value.absent(),
          }) =>
              AuditLogCompanion(
            id: id,
            timestamp: timestamp,
            userQuery: userQuery,
            llmInterpretation: llmInterpretation,
            actionType: actionType,
            actionParams: actionParams,
            policyResult: policyResult,
            userDecision: userDecision,
            actionResult: actionResult,
            error: error,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int timestamp,
            required String userQuery,
            Value<String?> llmInterpretation = const Value.absent(),
            required String actionType,
            Value<String?> actionParams = const Value.absent(),
            required String policyResult,
            Value<String?> userDecision = const Value.absent(),
            Value<String?> actionResult = const Value.absent(),
            Value<String?> error = const Value.absent(),
          }) =>
              AuditLogCompanion.insert(
            id: id,
            timestamp: timestamp,
            userQuery: userQuery,
            llmInterpretation: llmInterpretation,
            actionType: actionType,
            actionParams: actionParams,
            policyResult: policyResult,
            userDecision: userDecision,
            actionResult: actionResult,
            error: error,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AuditLogTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditLogTable,
    AuditLogData,
    $$AuditLogTableFilterComposer,
    $$AuditLogTableOrderingComposer,
    $$AuditLogTableAnnotationComposer,
    $$AuditLogTableCreateCompanionBuilder,
    $$AuditLogTableUpdateCompanionBuilder,
    (AuditLogData, BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData>),
    AuditLogData,
    PrefetchHooks Function()>;
typedef $$SearchCacheTableCreateCompanionBuilder = SearchCacheCompanion
    Function({
  required String queryHash,
  required String query,
  required String results,
  required String source,
  required int createdAt,
  required int expiresAt,
  Value<int> rowid,
});
typedef $$SearchCacheTableUpdateCompanionBuilder = SearchCacheCompanion
    Function({
  Value<String> queryHash,
  Value<String> query,
  Value<String> results,
  Value<String> source,
  Value<int> createdAt,
  Value<int> expiresAt,
  Value<int> rowid,
});

class $$SearchCacheTableFilterComposer
    extends Composer<_$AppDatabase, $SearchCacheTable> {
  $$SearchCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get queryHash => $composableBuilder(
      column: $table.queryHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get query => $composableBuilder(
      column: $table.query, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get results => $composableBuilder(
      column: $table.results, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));
}

class $$SearchCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchCacheTable> {
  $$SearchCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get queryHash => $composableBuilder(
      column: $table.queryHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get query => $composableBuilder(
      column: $table.query, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get results => $composableBuilder(
      column: $table.results, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));
}

class $$SearchCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchCacheTable> {
  $$SearchCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get queryHash =>
      $composableBuilder(column: $table.queryHash, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get results =>
      $composableBuilder(column: $table.results, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$SearchCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SearchCacheTable,
    SearchCacheData,
    $$SearchCacheTableFilterComposer,
    $$SearchCacheTableOrderingComposer,
    $$SearchCacheTableAnnotationComposer,
    $$SearchCacheTableCreateCompanionBuilder,
    $$SearchCacheTableUpdateCompanionBuilder,
    (
      SearchCacheData,
      BaseReferences<_$AppDatabase, $SearchCacheTable, SearchCacheData>
    ),
    SearchCacheData,
    PrefetchHooks Function()> {
  $$SearchCacheTableTableManager(_$AppDatabase db, $SearchCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> queryHash = const Value.absent(),
            Value<String> query = const Value.absent(),
            Value<String> results = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> expiresAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SearchCacheCompanion(
            queryHash: queryHash,
            query: query,
            results: results,
            source: source,
            createdAt: createdAt,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String queryHash,
            required String query,
            required String results,
            required String source,
            required int createdAt,
            required int expiresAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SearchCacheCompanion.insert(
            queryHash: queryHash,
            query: query,
            results: results,
            source: source,
            createdAt: createdAt,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SearchCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SearchCacheTable,
    SearchCacheData,
    $$SearchCacheTableFilterComposer,
    $$SearchCacheTableOrderingComposer,
    $$SearchCacheTableAnnotationComposer,
    $$SearchCacheTableCreateCompanionBuilder,
    $$SearchCacheTableUpdateCompanionBuilder,
    (
      SearchCacheData,
      BaseReferences<_$AppDatabase, $SearchCacheTable, SearchCacheData>
    ),
    SearchCacheData,
    PrefetchHooks Function()>;
typedef $$QuizzesTableCreateCompanionBuilder = QuizzesCompanion Function({
  required String id,
  Value<String?> sourcePdfPath,
  required String title,
  required String questions,
  Value<int?> score,
  required int totalQuestions,
  Value<int?> completedAt,
  required int createdAt,
  Value<int> rowid,
});
typedef $$QuizzesTableUpdateCompanionBuilder = QuizzesCompanion Function({
  Value<String> id,
  Value<String?> sourcePdfPath,
  Value<String> title,
  Value<String> questions,
  Value<int?> score,
  Value<int> totalQuestions,
  Value<int?> completedAt,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$QuizzesTableFilterComposer
    extends Composer<_$AppDatabase, $QuizzesTable> {
  $$QuizzesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourcePdfPath => $composableBuilder(
      column: $table.sourcePdfPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questions => $composableBuilder(
      column: $table.questions, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$QuizzesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizzesTable> {
  $$QuizzesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourcePdfPath => $composableBuilder(
      column: $table.sourcePdfPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questions => $composableBuilder(
      column: $table.questions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$QuizzesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizzesTable> {
  $$QuizzesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourcePdfPath => $composableBuilder(
      column: $table.sourcePdfPath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get questions =>
      $composableBuilder(column: $table.questions, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$QuizzesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuizzesTable,
    Quizze,
    $$QuizzesTableFilterComposer,
    $$QuizzesTableOrderingComposer,
    $$QuizzesTableAnnotationComposer,
    $$QuizzesTableCreateCompanionBuilder,
    $$QuizzesTableUpdateCompanionBuilder,
    (Quizze, BaseReferences<_$AppDatabase, $QuizzesTable, Quizze>),
    Quizze,
    PrefetchHooks Function()> {
  $$QuizzesTableTableManager(_$AppDatabase db, $QuizzesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizzesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizzesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizzesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> sourcePdfPath = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> questions = const Value.absent(),
            Value<int?> score = const Value.absent(),
            Value<int> totalQuestions = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizzesCompanion(
            id: id,
            sourcePdfPath: sourcePdfPath,
            title: title,
            questions: questions,
            score: score,
            totalQuestions: totalQuestions,
            completedAt: completedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> sourcePdfPath = const Value.absent(),
            required String title,
            required String questions,
            Value<int?> score = const Value.absent(),
            required int totalQuestions,
            Value<int?> completedAt = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizzesCompanion.insert(
            id: id,
            sourcePdfPath: sourcePdfPath,
            title: title,
            questions: questions,
            score: score,
            totalQuestions: totalQuestions,
            completedAt: completedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuizzesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuizzesTable,
    Quizze,
    $$QuizzesTableFilterComposer,
    $$QuizzesTableOrderingComposer,
    $$QuizzesTableAnnotationComposer,
    $$QuizzesTableCreateCompanionBuilder,
    $$QuizzesTableUpdateCompanionBuilder,
    (Quizze, BaseReferences<_$AppDatabase, $QuizzesTable, Quizze>),
    Quizze,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatsTableTableManager get chats =>
      $$ChatsTableTableManager(_db, _db.chats);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$DownloadedModelsTableTableManager get downloadedModels =>
      $$DownloadedModelsTableTableManager(_db, _db.downloadedModels);
  $$UsageLogsTableTableManager get usageLogs =>
      $$UsageLogsTableTableManager(_db, _db.usageLogs);
  $$ModelCacheTableTableManager get modelCache =>
      $$ModelCacheTableTableManager(_db, _db.modelCache);
  $$AutomationFlowsTableTableManager get automationFlows =>
      $$AutomationFlowsTableTableManager(_db, _db.automationFlows);
  $$FlowExecutionsTableTableManager get flowExecutions =>
      $$FlowExecutionsTableTableManager(_db, _db.flowExecutions);
  $$AuditLogTableTableManager get auditLog =>
      $$AuditLogTableTableManager(_db, _db.auditLog);
  $$SearchCacheTableTableManager get searchCache =>
      $$SearchCacheTableTableManager(_db, _db.searchCache);
  $$QuizzesTableTableManager get quizzes =>
      $$QuizzesTableTableManager(_db, _db.quizzes);
}
